import PyPDF2
import google.generativeai as genai
from flask import Flask, request, render_template, jsonify, redirect, url_for, flash, session
from langchain_community.vectorstores import FAISS
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.embeddings import HuggingFaceEmbeddings
import os
import numpy as np
import glob
import logging
import uuid
import hashlib
from datetime import datetime, timedelta
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from sqlalchemy.dialects.mysql import JSON

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.FileHandler("app.log"), logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

# Konfigurasi API Key untuk Google Generative AI
my_api_key_gemini = os.environ.get('GEMINI_API_KEY', 'AIzaSyBP4FOs_NO8pxS-JgqQ_xQk0g62Z_Q74OU')
try:
    genai.configure(api_key=my_api_key_gemini)
    # List available models
    logger.info("Available Gemini models:")
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            logger.info(f" - {m.name}")
except Exception as e:
    logger.error(f"Failed to configure Gemini API: {e}")

app = Flask(__name__)
app.secret_key = os.environ.get('FLASK_SECRET_KEY', 'development-secret-key')
app.config['SESSION_TYPE'] = 'filesystem'
app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(hours=5)

# Konfigurasi database
db_user = os.environ.get('DB_USER', 'root')
db_password = os.environ.get('DB_PASSWORD', '')  # kosongin default password
db_host = os.environ.get('DB_HOST', 'localhost')
db_name = os.environ.get('DB_NAME', 'pdf_qa_app')

app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://{db_user}:{db_password}@{db_host}/{db_name}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False


# Password untuk upload file
UPLOAD_PASSWORD = os.environ.get('UPLOAD_PASSWORD', 'Trisakti_2025')

# Folder yang berisi semua file PDF
data_folder = 'data/'
faiss_indices_folder = 'faiss_indices/'

# Memastikan folder indeks dan data ada
os.makedirs(faiss_indices_folder, exist_ok=True)
os.makedirs(data_folder, exist_ok=True)

# Inisialisasi database
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# Cache untuk menyimpan vektor store aktif per sesi
vector_store_cache = {}

# Model database
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    is_admin = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.now)
    last_login = db.Column(db.DateTime)
    sessions = db.relationship('UserSession', backref='user', lazy='dynamic', cascade='all, delete-orphan')
    
    def set_password(self, password):
        self.password_hash = hashlib.sha256(password.encode()).hexdigest()
    
    def check_password(self, password):
        return self.password_hash == hashlib.sha256(password.encode()).hexdigest()

class UserSession(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.String(64), unique=True, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id', ondelete='CASCADE'))
    created_at = db.Column(db.DateTime, default=datetime.now)
    last_activity = db.Column(db.DateTime, default=datetime.now)
    active_pdf = db.Column(db.String(255), nullable=True)
    
    def update_activity(self):
        self.last_activity = datetime.now()
        db.session.commit()

class Document(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    filename = db.Column(db.String(255), unique=True, nullable=False)
    upload_date = db.Column(db.DateTime, default=datetime.now)
    uploaded_by = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
    file_size = db.Column(db.Integer, nullable=False)
    num_pages = db.Column(db.Integer, nullable=False)
    description = db.Column(db.Text, nullable=True)
    document_queries = db.relationship('Query', backref='document', lazy='dynamic')

class Query(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.String(64), db.ForeignKey('user_session.session_id', ondelete='CASCADE'), nullable=False)
    document_id = db.Column(db.Integer, db.ForeignKey('document.id'), nullable=False)
    question = db.Column(db.Text, nullable=False)
    answer = db.Column(db.Text, nullable=False)
    language = db.Column(db.String(10), default='id')
    timestamp = db.Column(db.DateTime, default=datetime.now)
    feedbacks = db.relationship('Feedback', backref='parent_query', lazy='dynamic', cascade='all, delete-orphan')

class Feedback(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    query_id = db.Column(db.Integer, db.ForeignKey('query.id', ondelete='CASCADE'), nullable=False)
    feedback_type = db.Column(db.String(20), nullable=False)  # 'satisfied' atau 'unsatisfied'
    message = db.Column(db.Text, nullable=True)
    timestamp = db.Column(db.DateTime, default=datetime.now)
    
# Fungsi helper untuk sesi
def create_session_id():
    return str(uuid.uuid4())

def get_or_create_session():
    if 'session_id' not in session:
        session['session_id'] = create_session_id()
        # Simpan sesi baru ke database jika user terautentikasi
        if 'user_id' in session:
            user_session = UserSession(
                session_id=session['session_id'],
                user_id=session['user_id']
            )
            db.session.add(user_session)
            db.session.commit()
    return session['session_id']

def get_active_pdf():
    session_id = get_or_create_session()
    user_session = UserSession.query.filter_by(session_id=session_id).first()
    if user_session:
        return user_session.active_pdf
    return None

def set_active_pdf(pdf_filename):
    session_id = get_or_create_session()
    user_session = UserSession.query.filter_by(session_id=session_id).first()
    if user_session:
        user_session.active_pdf = pdf_filename
        user_session.update_activity()
    else:
        user_session = UserSession(session_id=session_id, active_pdf=pdf_filename)
        db.session.add(user_session)
        db.session.commit()

# Fungsi untuk mendapatkan daftar PDF yang tersedia
def get_available_pdfs():
    pdf_files = glob.glob(os.path.join(data_folder, '*.pdf'))
    return [os.path.basename(pdf) for pdf in pdf_files]

# Fungsi ekstraksi teks dari PDF
def extract_text_from_pdf(pdf_path):
    try:
        with open(pdf_path, 'rb') as file:
            reader = PyPDF2.PdfReader(file)
            text = ''
            total_pages = len(reader.pages)
            logger.info(f"Processing PDF: {pdf_path} with {total_pages} pages")
            
            for i, page in enumerate(reader.pages):
                if i % 10 == 0:  # Log progress for large documents
                    logger.info(f"Processing page {i+1}/{total_pages}")
                text += page.extract_text() or ""  # Handle None returns
            
            logger.info(f"Extracted text from {pdf_path} (length: {len(text)} chars)")
            return text
    except Exception as e:
        logger.error(f"Error extracting text from PDF {pdf_path}: {e}")
        return ""

# Fungsi untuk memproses PDF dan membuat vektor store
def process_pdf(pdf_filename):
    pdf_path = os.path.join(data_folder, pdf_filename)
    faiss_index_path = os.path.join(faiss_indices_folder, pdf_filename.replace('.pdf', ''))
    
    if not os.path.exists(pdf_path):
        logger.error(f"PDF file not found: {pdf_path}")
        return None
    
    try:
        if not os.path.exists(faiss_index_path):
            logger.info(f"Creating new FAISS index for {pdf_filename}")
            pdf_text = extract_text_from_pdf(pdf_path)
            
            if not pdf_text:
                logger.error(f"No text extracted from {pdf_filename}")
                return None
                
            # Gunakan chunk size yang lebih reasonable untuk text splitting
            text_splitter = RecursiveCharacterTextSplitter(
                chunk_size=1000000000,
                chunk_overlap=200000000,
                separators=["\n\n", "\n", ".", "!", "?", ",", " ", ""],
                length_function=len
            )
            texts = text_splitter.split_text(pdf_text)
            
            logger.info(f"Split text into {len(texts)} chunks")
            
            # Gunakan embedding model yang lebih baik untuk bahasa Indonesia
            embeddings = HuggingFaceEmbeddings(
                model_name="sentence-transformers/all-MiniLM-L6-v2",
                model_kwargs={'device': 'cpu'},
                encode_kwargs={'normalize_embeddings': True}
            )
            
            vector_store = FAISS.from_texts(texts, embeddings)
            vector_store.save_local(faiss_index_path)
            logger.info(f"FAISS index saved to {faiss_index_path}")
        else:
            logger.info(f"Loading existing FAISS index for {pdf_filename}")
            embeddings = HuggingFaceEmbeddings(
                model_name="sentence-transformers/all-MiniLM-L6-v2",
                model_kwargs={'device': 'cpu'},
                encode_kwargs={'normalize_embeddings': True}
            )
            vector_store = FAISS.load_local(faiss_index_path, embeddings, allow_dangerous_deserialization=True)
        
        return vector_store
    except Exception as e:
        logger.error(f"Error processing PDF {pdf_filename}: {e}")
        return None

# Fungsi untuk mendapatkan vector store dari cache atau memproses PDF
def get_vector_store(pdf_filename):
    session_id = get_or_create_session()
    cache_key = f"{session_id}:{pdf_filename}"
    
    # Cek apakah vector store sudah ada di cache
    if cache_key in vector_store_cache:
        return vector_store_cache[cache_key]
    
    # Jika tidak, proses PDF dan simpan ke cache
    vector_store = process_pdf(pdf_filename)
    if vector_store:
        vector_store_cache[cache_key] = vector_store
        
        # Membersihkan cache jika terlalu besar (simplifikasi, bisa dioptimalkan)
        if len(vector_store_cache) > 100:
            # Hapus 20% entri cache terlama
            keys_to_remove = list(vector_store_cache.keys())[:20]
            for key in keys_to_remove:
                vector_store_cache.pop(key, None)
                
    return vector_store

# Fungsi untuk menghasilkan respons dengan Gemini (IMPROVED)
def generate_response(prompt, vector_store, language="id"):
    # Validasi input agar tidak kosong
    if not prompt.strip():
        return "Pertanyaan tidak boleh kosong."

    try:
        # Set up retriever dari vector store dengan lebih banyak dokumen relevan
        retriever = vector_store.as_retriever(search_kwargs={"k": 5})
        
        # Ambil teks yang paling relevan dari FAISS
        retrieved_docs = retriever.get_relevant_documents(prompt)

        # Jika tidak ada dokumen yang ditemukan, berikan respons default
        if not retrieved_docs:
            return "Maaf, saya tidak menemukan informasi yang relevan dalam dokumen."

        # Gabungkan teks dari dokumen hasil retrieval dengan pemisah yang jelas
        relevant_texts = []
        for i, doc in enumerate(retrieved_docs):
            relevant_texts.append(f"[Bagian {i+1}]\n{doc.page_content}\n")
        
        relevant_text = "\n".join(relevant_texts)
        
        logger.info(f"Retrieved {len(retrieved_docs)} relevant documents for query: {prompt[:50]}...")

        # Format prompt yang lebih terstruktur untuk hasil yang lebih baik
        if language.lower() == 'id':
            full_prompt = f"""Berikut adalah bagian-bagian dari dokumen yang relevan dengan pertanyaan:

{relevant_text}

Berdasarkan informasi di atas, jawab pertanyaan berikut dengan detail dan akurat:
Pertanyaan: {prompt}

Jawaban:"""
        else:
            full_prompt = f"""Here are the relevant sections from the document:

{relevant_text}

Based on the information above, answer the following question detiled and accurately:
Question: {prompt}


Answer:"""

        # Try different Gemini models in order of preference
        models_to_try = ['gemini-2.0-flash', 'gemini-1.5-pro', 'gemini-1.5-flash']
        
        for model_name in models_to_try:
            try:
                logger.info(f"Trying model: {model_name}")
                model = genai.GenerativeModel(model_name)
                
                # Generate dengan parameter yang lebih spesifik
                response = model.generate_content(
                    full_prompt,
                    generation_config=genai.GenerationConfig(
                        temperature=0.1,  # Lebih deterministik untuk jawaban yang akurat
                        top_p=0.8,
                        top_k=40,
                        max_output_tokens=2048,
                    )
                )

                # Periksa apakah respons dari model kosong
                if response and hasattr(response, "text") and response.text:
                    logger.info(f"Successfully generated response with model: {model_name}")
                    return response.text
                
            except Exception as e:
                logger.warning(f"Failed with model {model_name}: {e}")
                continue
        
        # If all models fail, return error message
        logger.error("All Gemini models failed to generate response")
        return "Maaf, saya tidak bisa memberikan jawaban saat ini. Semua model gagal memberikan respons."

    except Exception as e:
        logger.error(f"Error generating response: {e}")
        # Log the full error for debugging
        import traceback
        logger.error(f"Full error traceback: {traceback.format_exc()}")
        return f"Terjadi kesalahan: {str(e)}"

# Routes
@app.route('/')
def index():
    # Check if user is logged in
    if 'user_id' not in session:
        # If not logged in, redirect to login page
        return redirect(url_for('login'))
    
    # If user is logged in, proceed to the chatbot interface
    pdfs = get_available_pdfs()
    active_pdf = get_active_pdf()
    now = datetime.now()  # Tambahkan waktu sekarang untuk timestamp
    
    if not pdfs:
        flash("Tidak ada file PDF di folder 'data/'. Silakan tambahkan beberapa file PDF terlebih dahulu.", "warning")
    
    return render_template('index.html', pdfs=pdfs, active_pdf=active_pdf, now=now)

@app.route('/select_pdf', methods=['POST'])
def select_pdf():
    # Check if user is logged in
    if 'user_id' not in session:
        # If not logged in, redirect to login page
        return redirect(url_for('login'))
    
    # If user is logged in, proceed to the chatbot interface
    pdf_filename = request.form.get('pdf_file')
    if not pdf_filename:
        flash("Silakan pilih file PDF", "error")
        return redirect(url_for('index'))
    
    # Cari dokumen di database atau buat baru jika belum ada
    document = Document.query.filter_by(filename=pdf_filename).first()
    if not document:
        try:
            # Ambil informasi file untuk dokumen baru
            pdf_path = os.path.join(data_folder, pdf_filename)
            file_size = os.path.getsize(pdf_path)
            
            with open(pdf_path, 'rb') as file:
                reader = PyPDF2.PdfReader(file)
                num_pages = len(reader.pages)
            
            # Simpan informasi dokumen ke database
            document = Document(
                filename=pdf_filename,
                file_size=file_size,
                num_pages=num_pages,
                uploaded_by=session.get('user_id')
            )
            db.session.add(document)
            db.session.commit()
        except Exception as e:
            logger.error(f"Error creating document record: {e}")
    
    # Proses PDF dan simpan ke cache
    vector_store = get_vector_store(pdf_filename)
    
    if vector_store is None:
        flash(f"Gagal memproses {pdf_filename}. Periksa log untuk detail.", "error")
        return redirect(url_for('index'))
    
    # Set PDF aktif untuk sesi ini
    set_active_pdf(pdf_filename)
    
    flash(f"File {pdf_filename} berhasil dipilih", "success")
    return redirect(url_for('index'))

@app.route('/ask', methods=['POST'])
def ask():
    try:
        data = request.get_json()
        question = data.get('question', '')
        language = data.get('language', 'id')
        logger.info(f"Received question: {question[:50]}...")

        # Dapatkan PDF aktif untuk sesi ini
        active_pdf = get_active_pdf()
        if not active_pdf:
            return jsonify({"error": "Silakan pilih file PDF terlebih dahulu"}), 400

        # Dapatkan vektor store dari cache atau proses ulang
        vector_store = get_vector_store(active_pdf)
        if not vector_store:
            return jsonify({"error": "Gagal memproses dokumen. Silakan coba lagi."}), 500

        # Generate response
        response = generate_response(question, vector_store, language)
        
        # Simpan pertanyaan dan jawaban ke database
        try:
            session_id = get_or_create_session()
            document = Document.query.filter_by(filename=active_pdf).first()
            
            if document:
                query = Query(
                    session_id=session_id,
                    document_id=document.id,
                    question=question,
                    answer=response,
                    language=language
                )
                db.session.add(query)
                db.session.commit()
        except Exception as e:
            logger.error(f"Error saving query to database: {e}")
            # Lanjutkan meskipun gagal menyimpan ke database
        
        return jsonify({"response": response})
    
    except Exception as e:
        logger.error(f"Error in /ask endpoint: {e}")
        return jsonify({"error": f"Terjadi kesalahan: {str(e)}"}), 500

@app.route('/feedback', methods=['POST'])
def feedback():
    try:
        data = request.get_json()
        feedback_type = data.get('type', 'unknown')  # 'satisfied' atau 'unsatisfied'
        message = data.get('message', '')
        question = data.get('question', '')
        response = data.get('response', '')
        
        # Simpan feedback ke database jika tersedia informasi query
        if question and response:
            try:
                # Cari query terbaru dengan pertanyaan dan jawaban yang cocok
                query_obj = Query.query.filter_by(
                    question=question,
                    answer=response
                ).order_by(Query.timestamp.desc()).first()
                
                if query_obj:
                    # Simpan feedback ke database
                    feedback_entry = Feedback(
                        query_id=query_obj.id,
                        feedback_type=feedback_type,
                        message=message
                    )
                    db.session.add(feedback_entry)
                    db.session.commit()
            except Exception as e:
                logger.error(f"Error saving feedback to database: {e}")
        
        # Tetap simpan ke log file untuk kompatibilitas
        feedback_data = {
            "timestamp": datetime.now().isoformat(),
            "type": feedback_type,
            "message": message,
            "question": question,
            "response": response,
            "pdf": get_active_pdf(),
            "session_id": get_or_create_session()
        }
        
        with open('feedback_log.txt', 'a') as f:
            f.write(f"{feedback_data}\n")
        
        logger.info(f"Feedback received: {feedback_type}")
        return jsonify({"status": "success"})
    except Exception as e:
        logger.error(f"Error saving feedback: {e}")
        return jsonify({"error": str(e)}), 500

# Autentikasi pengguna
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        is_admin = request.form.get('is_admin') == 'on'  # Checkbox value
        admin_code = request.form.get('admin_code')
        
        # Validasi input
        if not username or not email or not password:
            flash('Semua field harus diisi', 'error')
            return redirect(url_for('register'))
        
        # Validasi kode admin jika user ingin menjadi admin
        ADMIN_CODE = "kode_rahasia_2024"  
        if is_admin:
            if admin_code != ADMIN_CODE:
                flash('Kode admin tidak valid', 'error')
                return redirect(url_for('register'))
        
        # Cek apakah user sudah ada
        existing_user = User.query.filter_by(username=username).first()
        if existing_user:
            flash('Username sudah digunakan', 'error')
            return redirect(url_for('register'))
        
        existing_email = User.query.filter_by(email=email).first()
        if existing_email:
            flash('Email sudah terdaftar', 'error')
            return redirect(url_for('register'))
        
        # Buat user baru
        new_user = User(username=username, email=email)
        new_user.set_password(password)
        
        # Set user pertama sebagai admin, atau jika admin code valid
        if User.query.count() == 0 or is_admin:
            new_user.is_admin = True
        
        db.session.add(new_user)
        db.session.commit()
        
        flash('Registrasi berhasil! Silakan login.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        user = User.query.filter_by(username=username).first()
        
        if user and user.check_password(password):
            # Hapus sesi lama jika ada
            if 'session_id' in session:
                old_session = UserSession.query.filter_by(session_id=session['session_id']).first()
                if old_session:
                    # Get all queries for this session
                    queries = Query.query.filter_by(session_id=old_session.session_id).all()
                    
                    # Delete all feedback for each query
                    for query in queries:
                        Feedback.query.filter_by(query_id=query.id).delete()
                    
                    # Delete all queries
                    Query.query.filter_by(session_id=old_session.session_id).delete()
                    
                    # Delete the old session
                    db.session.delete(old_session)
                    db.session.commit()
            
            # Update last login time
            user.last_login = datetime.now()
            db.session.commit()
            
            # Clear old session data
            session.clear()
            
            # Set session data baru
            session['user_id'] = user.id
            session['username'] = user.username
            session['is_admin'] = user.is_admin
            
            # Create new session entry
            new_session_id = create_session_id()
            session['session_id'] = new_session_id
            
            # Create new session in database
            user_session = UserSession(
                session_id=new_session_id,
                user_id=user.id
            )
            db.session.add(user_session)
            db.session.commit()
            
            flash(f'Selamat datang kembali, {user.username}!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Username atau password salah', 'error')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    if 'user_id' in session:
        if 'session_id' in session:
            user_session = UserSession.query.filter_by(session_id=session['session_id']).first()
            if user_session:
                # First, get all queries for this session
                queries = Query.query.filter_by(session_id=user_session.session_id).all()
                
                # Delete all feedback for each query
                for query in queries:
                    Feedback.query.filter_by(query_id=query.id).delete()
                
                # Now delete all queries
                Query.query.filter_by(session_id=user_session.session_id).delete()
                
                # Finally delete the user session
                db.session.delete(user_session)
                db.session.commit()
        
    session.clear()
    flash('Anda berhasil logout', 'success')
    return redirect(url_for('login'))


# New route to manage user sessions (admin only)
@app.route('/admin/sessions')
def admin_sessions():
    if not session.get('is_admin', False):
        flash('Access denied. Admin privileges required.', 'error')
        return redirect(url_for('index'))
    
    # Get all user sessions
    sessions = db.session.query(UserSession, User).join(User).order_by(UserSession.last_activity.desc()).all()
    
    return render_template('admin_sessions.html', sessions=sessions)

@app.route('/admin/delete_session/<int:session_id>', methods=['POST'])
def delete_session(session_id):
    if not session.get('is_admin', False):
        return jsonify({'error': 'Unauthorized'}), 403
    
    try:
        user_session = UserSession.query.get(session_id)
        if user_session:
            # Get all queries for this session
            queries = Query.query.filter_by(session_id=user_session.session_id).all()
            
            # Delete all feedback for each query
            for query in queries:
                Feedback.query.filter_by(query_id=query.id).delete()
            
            # Delete all queries
            Query.query.filter_by(session_id=user_session.session_id).delete()
            
            # Remove from cache
            cache_keys_to_remove = []
            for key in vector_store_cache.keys():
                if key.startswith(user_session.session_id):
                    cache_keys_to_remove.append(key)
            
            for key in cache_keys_to_remove:
                vector_store_cache.pop(key, None)
            
            # Delete the session
            db.session.delete(user_session)
            db.session.commit()
            
            return jsonify({'success': True, 'message': 'Session deleted successfully'})
        else:
            return jsonify({'error': 'Session not found'}), 404
    except Exception as e:
        logger.error(f"Error deleting session: {e}")
        db.session.rollback()
        return jsonify({'error': str(e)}), 500

# CLI command to cleanup old sessions
@app.cli.command("cleanup-sessions")
def cleanup_sessions():
    """Cleanup old sessions."""
    cutoff_date = datetime.now() - timedelta(days=7)
    old_sessions = UserSession.query.filter(UserSession.last_activity < cutoff_date).all()
    
    count = 0
    for old_session in old_sessions:
        # Get all queries for this session
        queries = Query.query.filter_by(session_id=old_session.session_id).all()
        
        # Delete all feedback for each query
        for query in queries:
            Feedback.query.filter_by(query_id=query.id).delete()
        
        # Delete all queries
        Query.query.filter_by(session_id=old_session.session_id).delete()
        
        # Delete the session
        db.session.delete(old_session)
        count += 1
    
    db.session.commit()
    print(f"Cleaned up {count} old sessions")

# Add this to your Flask app
@app.route('/delete_pdf/<int:pdf_id>', methods=['DELETE'])
def delete_pdf(pdf_id):
    try:
        # Get document from database
        document = Document.query.get(pdf_id)
        
        if not document:
            # Try to find document by filename index
            pdfs = get_available_pdfs()
            if 0 <= pdf_id - 1 < len(pdfs):
                filename = pdfs[pdf_id - 1]
                document = Document.query.filter_by(filename=filename).first()
        
        if not document:
            return jsonify({'error': 'Document not found', 'success': False}), 404
        
        filename = document.filename
        file_path = os.path.join(data_folder, filename)
        
        # Delete the file from disk
        if os.path.exists(file_path):
            os.remove(file_path)
        
        # Delete FAISS index if exists
        faiss_index_path = os.path.join(faiss_indices_folder, filename.replace('.pdf', ''))
        if os.path.exists(faiss_index_path):
            import shutil
            shutil.rmtree(faiss_index_path)
        
        # Delete from database
        db.session.delete(document)
        db.session.commit()
        
        # Clean up cache if exists
        for key in list(vector_store_cache.keys()):
            if filename in key:
                vector_store_cache.pop(key, None)
                
        return jsonify({
            'success': True, 
            'message': f'File {filename} has been deleted successfully'
        })
    
    except Exception as e:
        logger.error(f"Error deleting PDF: {e}")
        db.session.rollback()
        return jsonify({'error': str(e), 'success': False}), 500

# Modify the 'upload_pdf' route to return document info
@app.route('/upload', methods=['GET', 'POST'])
def upload_pdf():
    if request.method == 'POST':
        # Check if password is provided and correct
        password = request.form.get('password', '')
        if password != UPLOAD_PASSWORD:
            flash('Password salah. Akses ditolak.', 'error')
            return redirect(request.url)
            
        if 'pdf_file' not in request.files:
            flash('No file part', 'error')
            return redirect(request.url)
        
        file = request.files['pdf_file']
        
        if file.filename == '':
            flash('No selected file', 'error')
            return redirect(request.url)
        
        if file and file.filename.endswith('.pdf'):
            filename = os.path.basename(file.filename)
            file_path = os.path.join(data_folder, filename)
            file.save(file_path)
            
            # Tambahkan dokumen ke database
            try:
                file_size = os.path.getsize(file_path)
                
                with open(file_path, 'rb') as f:
                    reader = PyPDF2.PdfReader(f)
                    num_pages = len(reader.pages)
                
                # Check if document already exists
                existing_doc = Document.query.filter_by(filename=filename).first()
                if existing_doc:
                    # Update existing document
                    existing_doc.file_size = file_size
                    existing_doc.num_pages = num_pages
                    existing_doc.upload_date = datetime.now()
                    document = existing_doc
                else:
                    # Create new document
                    document = Document(
                        filename=filename,
                        file_size=file_size,
                        num_pages=num_pages,
                        uploaded_by=session.get('user_id')
                    )
                    db.session.add(document)
                
                db.session.commit()
                
                # Clear any existing FAISS index to force reprocessing
                faiss_index_path = os.path.join(faiss_indices_folder, filename.replace('.pdf', ''))
                if os.path.exists(faiss_index_path):
                    import shutil
                    shutil.rmtree(faiss_index_path)
                
                flash(f'File {filename} successfully uploaded', 'success')
                return redirect(url_for('index'))
            except Exception as e:
                logger.error(f"Error adding document to database: {e}")
                flash(f'Error processing document: {str(e)}', 'error')
                return redirect(request.url)
        else:
            flash('Only PDF files are allowed', 'error')
    
    # Get document info for all PDFs
    pdfs = get_available_pdfs()
    documents = {}
    
    for pdf in pdfs:
        doc = Document.query.filter_by(filename=pdf).first()
        if doc:
            documents[pdf] = {
                'id': doc.id,
                'file_size': doc.file_size,
                'num_pages': doc.num_pages,
                'upload_date': doc.upload_date
            }
    
    return render_template('upload.html', pdfs=pdfs, documents=documents)

# Add this to modify your admin_dashboard route
@app.route('/admin')
def admin_dashboard():
    # Check if user is logged in and is admin
    if not session.get('is_admin', False):
        flash('Access denied. Admin privileges required.', 'error')
        return redirect(url_for('index'))
    
    # Get data for dashboard
    users_count = User.query.count() or 0
    documents_count = Document.query.count() or 0
    queries_count = Query.query.count() or 0
    
    # Get documents with query counts
    recent_documents = []
    try:
        # Subquery to get query counts for each document
        query_counts = db.session.query(
            Query.document_id,
            db.func.count(Query.id).label('query_count')
        ).group_by(Query.document_id).subquery()
        
        # Join with documents table
        document_query = db.session.query(
            Document, 
            db.func.coalesce(query_counts.c.query_count, 0).label('query_count')
        ).outerjoin(
            query_counts, Document.id == query_counts.c.document_id
        ).order_by(Document.upload_date.desc()).limit(10)
        
        # Process results
        for doc, query_count in document_query:
            # Add query_count attribute to document object
            doc.query_count = query_count
            recent_documents.append(doc)
    except Exception as e:
        logger.error(f"Error getting documents with query counts: {e}")
        # Fallback to simple document query
        recent_documents = Document.query.order_by(Document.upload_date.desc()).limit(10).all()
        for doc in recent_documents:
            doc.query_count = 0
    
    active_sessions = UserSession.query.filter(
        UserSession.last_activity > datetime.now() - timedelta(minutes=30)
    ).count() or 0
    
    # Get query history by date for chart
    query_history_data = {}
    try:
        # Group queries by date
        query_dates = db.session.query(
            db.func.date(Query.timestamp).label('date'),
            db.func.count(Query.id).label('count')
        ).group_by(db.func.date(Query.timestamp)).order_by(db.func.date(Query.timestamp)).all()
        
        # Format dates for display
        for date, count in query_dates:
            formatted_date = date.strftime('%d %b')
            query_history_data[formatted_date] = count
        
        # If no data, provide sample data
        if not query_history_data:
            today = datetime.now()
            for i in range(7):
                date = today - timedelta(days=i)
                formatted_date = date.strftime('%d %b')
                query_history_data[formatted_date] = 0
    except Exception as e:
        logger.error(f"Error getting query history data: {e}")
    
    # Get feedback statistics
    feedback_stats = []
    try:
        feedback_stats = db.session.query(
            Feedback.feedback_type,
            db.func.count(Feedback.id).label('count')
        ).group_by(Feedback.feedback_type).all()
    except Exception as e:
        logger.error(f"Error getting feedback statistics: {e}")
    
    return render_template(
        'admin_dashboard.html',
        users_count=users_count,
        documents_count=documents_count,
        queries_count=queries_count,
        recent_documents=recent_documents,
        active_sessions=active_sessions,
        query_history_data=query_history_data,
        feedback_stats=feedback_stats
    )
    
# This is a simplified version that runs on request
@app.before_request
def cleanup_old_sessions():
    # Run cleanup occasionally (not on every request in production)
    if request.endpoint and request.endpoint != 'static' and np.random.random() < 0.01:
        try:
            # Delete sessions older than 7 days
            cutoff_date = datetime.now() - timedelta(days=7)
            old_sessions = UserSession.query.filter(UserSession.last_activity < cutoff_date).all()
            
            for old_session in old_sessions:
                # Get all queries for this session
                queries = Query.query.filter_by(session_id=old_session.session_id).all()
                
                # Delete all feedback for each query
                for query in queries:
                    Feedback.query.filter_by(query_id=query.id).delete()
                
                # Delete all queries
                Query.query.filter_by(session_id=old_session.session_id).delete()
                
                # Delete the session
                db.session.delete(old_session)
            
            # Clean up vector store cache for expired sessions
            session_ids = [s.session_id for s in old_sessions]
            for key in list(vector_store_cache.keys()):
                if key.split(':')[0] in session_ids:
                    vector_store_cache.pop(key, None)
            
            db.session.commit()
            logger.info(f"Cleaned up {len(old_sessions)} expired sessions")
        except Exception as e:
            logger.error(f"Error cleaning up old sessions: {e}")
            db.session.rollback()

# Database initialization
@app.cli.command("init-db")
def init_db():
    """Initialize the database."""
    db.create_all()
    print("Database tables created.")

# Create admin user
@app.cli.command("create-admin")
def create_admin():
    """Create admin user."""
    username = input("Admin username: ")
    email = input("Admin email: ")
    password = input("Admin password: ")
    
    # Check if admin already exists
    existing_admin = User.query.filter_by(username=username).first()
    if existing_admin:
        print("Admin user already exists.")
        return
    
    admin = User(username=username, email=email, is_admin=True)
    admin.set_password(password)
    db.session.add(admin)
    db.session.commit()
    print(f"Admin user '{username}' created successfully.")

if __name__ == '__main__':
    with app.app_context():
        # Create tables if they don't exist
        db.create_all()
    app.run(host="0.0.0.0", port=8000, debug=True)