from passlib.context import CryptContext

# Initialize password hashing context with bcrypt algorithm
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """
    Hashes a plain-text password using bcrypt.
    This is used when creating a new user or updating a password.
    """
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifies a plain-text password against a stored hashed password.
    Returns True if they match, False otherwise.
    """
    return pwd_context.verify(plain_password, hashed_password)
