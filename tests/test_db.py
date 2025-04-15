from database.database import engine
try:
    conn = engine.connect()
    print("✅ חיבור ל-DB הצליח!")
    conn.close()
except Exception as e:
    print(f"❌ שגיאה בחיבור ל-DB: {e}")
