import os
import sys

# Ensure backend directory is in python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app.core.security import (
    create_access_token,
    decode_access_token,
    generate_ticket_signature,
    hash_password,
    verify_password,
    verify_ticket_signature,
)
from app.core.seed import seed_database
from app.core.database import SessionLocal
from app.models.entities import User, Trip, Operator


def test_password_hashing():
    pw = "supersecret123"
    hashed = hash_password(pw)
    assert hashed != pw
    assert verify_password(pw, hashed) is True
    assert verify_password("wrongpassword", hashed) is False


def test_jwt_token_creation_and_decoding():
    data = {"sub": "123", "email": "test@ethioliner.com", "role": "PASSENGER"}
    token = create_access_token(data)
    assert isinstance(token, str)
    assert len(token.split(".")) == 3

    payload = decode_access_token(token)
    assert payload is not None
    assert payload["sub"] == "123"
    assert payload["email"] == "test@ethioliner.com"
    assert payload["role"] == "PASSENGER"


def test_ticket_tamper_proofing():
    ticket_id = "TCK-78421-1"
    trip_id = 1
    seat = "3A"

    sig = generate_ticket_signature(ticket_id, trip_id, seat)
    assert isinstance(sig, str)
    assert len(sig) > 0

    # Valid verification
    assert verify_ticket_signature(ticket_id, trip_id, seat, sig) is True

    # Tampered seat or trip must fail
    assert verify_ticket_signature(ticket_id, trip_id, "3B", sig) is False
    assert verify_ticket_signature(ticket_id, 2, seat, sig) is False
    assert verify_ticket_signature("TCK-FAKE", trip_id, seat, sig) is False


def test_database_seeding_and_entities():
    seed_database()
    db = SessionLocal()
    try:
        users = db.query(User).all()
        assert len(users) >= 2

        operators = db.query(Operator).all()
        assert len(operators) >= 3

        trips = db.query(Trip).all()
        assert len(trips) >= 2
    finally:
        db.close()


if __name__ == "__main__":
    test_password_hashing()
    test_jwt_token_creation_and_decoding()
    test_ticket_tamper_proofing()
    test_database_seeding_and_entities()
    print("All backend tests passed successfully!")
