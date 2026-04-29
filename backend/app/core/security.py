import hashlib
import hmac
import base64
import json
import time
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from app.core.config import settings


def hash_password(password: str) -> str:
    """Hashes a password with salt using SHA-256."""
    salt = settings.SECRET_KEY[:16].encode("utf-8")
    pw_bytes = password.encode("utf-8")
    hashed = hashlib.pbkdf2_hmac("sha256", pw_bytes, salt, 100000)
    return base64.b64encode(hashed).decode("utf-8")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifies a plain password against the stored hash."""
    expected_hash = hash_password(plain_password)
    return hmac.compare_digest(expected_hash, hashed_password)


def create_access_token(data: Dict[str, Any], expires_delta: Optional[timedelta] = None) -> str:
    """Creates a signed JWT-compatible token."""
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update({"exp": int(expire.timestamp()), "iat": int(now.timestamp())})

    # Header
    header = {"alg": "HS256", "typ": "JWT"}
    header_b64 = base64.urlsafe_b64encode(json.dumps(header).encode("utf-8")).decode("utf-8").rstrip("=")
    payload_b64 = base64.urlsafe_b64encode(json.dumps(to_encode).encode("utf-8")).decode("utf-8").rstrip("=")

    signature_input = f"{header_b64}.{payload_b64}".encode("utf-8")
    signature = hmac.new(settings.SECRET_KEY.encode("utf-8"), signature_input, hashlib.sha256).digest()
    signature_b64 = base64.urlsafe_b64encode(signature).decode("utf-8").rstrip("=")

    return f"{header_b64}.{payload_b64}.{signature_b64}"


def decode_access_token(token: str) -> Optional[Dict[str, Any]]:
    """Decodes and validates a signed JWT token."""
    try:
        parts = token.split(".")
        if len(parts) != 3:
            return None

        header_b64, payload_b64, signature_b64 = parts

        # Verify signature
        signature_input = f"{header_b64}.{payload_b64}".encode("utf-8")
        expected_sig = hmac.new(settings.SECRET_KEY.encode("utf-8"), signature_input, hashlib.sha256).digest()

        # Re-pad base64
        padded_sig = signature_b64 + "=" * (-len(signature_b64) % 4)
        actual_sig = base64.urlsafe_b64decode(padded_sig.encode("utf-8"))

        if not hmac.compare_digest(expected_sig, actual_sig):
            return None

        # Decode payload
        padded_payload = payload_b64 + "=" * (-len(payload_b64) % 4)
        payload = json.loads(base64.urlsafe_b64decode(padded_payload.encode("utf-8")).decode("utf-8"))

        # Check expiration
        exp = payload.get("exp")
        if exp and exp < time.time():
            return None

        return payload
    except Exception:
        return None
