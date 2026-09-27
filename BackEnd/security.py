import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Optional
import jwt
import os

SECRET_KEY = os.getenv("SECRET_KEY", "ChaveSecretaParaTokensJWT_GereUmaSegura")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24

try:
    from passlib.context import CryptContext
    pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
    USE_PASSLIB = True
except ImportError:
    USE_PASSLIB = False

def is_hashed(password_str: str) -> bool:
    if not password_str:
        return False
    return (
        password_str.startswith("$2b$") or 
        password_str.startswith("$2a$") or 
        password_str.startswith("$2y$") or 
        password_str.startswith("pbkdf2:sha256:") or
        password_str.startswith("$argon2") or
        password_str.startswith("$pbkdf2-sha256$")
    )

def truncate_password(password: str) -> str:
    if not password:
        return ""
    encoded = password.encode('utf-8')
    if len(encoded) > 64:
        return encoded[:64].decode('utf-8', errors='ignore')
    return password

def hash_password(password: str) -> str:
    if is_hashed(password):
        return password

    clean_password = truncate_password(password)

    if USE_PASSLIB:
        try:
            return pwd_context.hash(clean_password)
        except Exception:
            pass
    
    salt = secrets.token_hex(16)
    key = hashlib.pbkdf2_hmac('sha256', clean_password.encode('utf-8'), salt.encode('utf-8'), 100000)
    return f"pbkdf2:sha256:100000${salt}${key.hex()}"

def verify_password(plain_password: str, hashed_password: str) -> bool:
    if not hashed_password:
        return False
    
    clean_plain = truncate_password(plain_password)

    if USE_PASSLIB and (hashed_password.startswith("$2b$") or hashed_password.startswith("$2a$") or hashed_password.startswith("$2y$")):
        try:
            return pwd_context.verify(clean_plain, hashed_password)
        except Exception:
            pass
    
    if hashed_password.startswith("pbkdf2:sha256:"):
        try:
            parts = hashed_password.split("$")
            if len(parts) != 3:
                return False
            iterations = int(parts[0].split(":")[2])
            salt = parts[1]
            stored_key = parts[2]
            key = hashlib.pbkdf2_hmac('sha256', clean_plain.encode('utf-8'), salt.encode('utf-8'), iterations)
            return secrets.compare_digest(key.hex(), stored_key)
        except Exception:
            return False
            
    return plain_password == hashed_password

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str) -> Optional[dict]:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except Exception:
        return None
