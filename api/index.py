from flask import Flask, render_template
import sys
import os

# Tambahkan direktori induk ke path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import aplikasi Flask dari app.py
from app import app

# Panggil app secara langsung dengan WSGI handler
app = app