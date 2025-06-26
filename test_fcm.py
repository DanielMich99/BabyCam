#!/usr/bin/env python3
"""
Test script for FCM Push Notifications
Run this script to test if your Firebase configuration is working correctly.
"""

import os
import sys
import json
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_fcm_configuration():
    """Test FCM configuration and send a test notification"""
    
    print("🔍 Testing FCM Configuration...")
    
    # Check environment variables for FCM API V1
    firebase_project_id = os.getenv("FIREBASE_PROJECT_ID")
    credentials_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    
    print(f"✅ Firebase Project ID: {firebase_project_id or '❌ Missing'}")
    print(f"✅ Credentials Path: {credentials_path or '❌ Missing'}")
    
    if not all([firebase_project_id, credentials_path]):
        print("\n❌ Missing required environment variables!")
        print("Please check your .env file and ensure Firebase variables are set.")
        return False
    
    # Check if credentials file exists
    if not os.path.exists(credentials_path):
        print(f"\n❌ Credentials file not found: {credentials_path}")
        return False
    
    print(f"✅ Credentials file exists: {credentials_path}")
    
    # Test FCM service
    try:
        from app.utils.fcm_push import send_push_notifications
        
        # You'll need to provide a real FCM token for testing
        test_token = input("\n🔑 Enter a test FCM token (or press Enter to skip): ").strip()
        
        if test_token:
            print("📤 Sending test notification...")
            send_push_notifications(
                tokens=[test_token],
                title="🧪 Test Notification",
                body="This is a test notification from BabyCam!",
                project_id=firebase_project_id,
                credentials_path=credentials_path
            )
            print("✅ Test notification sent successfully!")
        else:
            print("⏭️  Skipping test notification")
        
        return True
        
    except ImportError as e:
        print(f"❌ Error importing FCM module: {e}")
        return False
    except Exception as e:
        print(f"❌ Error testing FCM: {e}")
        return False

def test_database_connection():
    """Test database connection and FCM token storage"""
    
    print("\n🔍 Testing Database Connection...")
    
    try:
        from database.database import SessionLocal
        from app.models.user_model import UserFCMToken
        
        db = SessionLocal()
        
        # Check if FCM tokens table exists and has data
        tokens = db.query(UserFCMToken).all()
        print(f"✅ Found {len(tokens)} FCM tokens in database")
        
        if tokens:
            print("📋 Registered tokens:")
            for token in tokens:
                print(f"  - {token.token[:20]}... (User ID: {token.user_id})")
        
        db.close()
        return True
        
    except Exception as e:
        print(f"❌ Database error: {e}")
        return False

def main():
    """Main test function"""
    
    print("🚀 BabyCam FCM Push Notification Test")
    print("=" * 50)
    
    # Test configuration
    config_ok = test_fcm_configuration()
    
    # Test database
    db_ok = test_database_connection()
    
    print("\n" + "=" * 50)
    print("📊 Test Results:")
    print(f"  Configuration: {'✅ PASS' if config_ok else '❌ FAIL'}")
    print(f"  Database: {'✅ PASS' if db_ok else '❌ FAIL'}")
    
    if config_ok and db_ok:
        print("\n🎉 All tests passed! Your FCM setup is ready.")
        print("\nNext steps:")
        print("1. Update your frontend with real Firebase credentials")
        print("2. Add notification sound files")
        print("3. Test with the actual app")
    else:
        print("\n⚠️  Some tests failed. Please check the configuration.")
        print("\nCommon fixes:")
        print("1. Ensure .env file has all required variables")
        print("2. Verify Firebase credentials are correct")
        print("3. Check database connection")

if __name__ == "__main__":
    main() 