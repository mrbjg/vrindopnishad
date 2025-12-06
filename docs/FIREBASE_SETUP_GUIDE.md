# Firebase Setup Guide for Vrindopnishad

This guide will help you configure Firebase for the Vrindopnishad application.

## Prerequisites
- A Google account
- Access to Firebase Console

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `vrindopnishad` (or your preferred name)
4. Accept Firebase terms and click "Continue"
5. Disable Google Analytics (optional) or configure it
6. Click "Create project"
7. Wait for project creation to complete

## Step 2: Enable Firestore Database

1. In your Firebase project, click on "Firestore Database" in the left sidebar
2. Click "Create database"
3. Choose "Start in production mode" (you can modify rules later)
4. Select a Cloud Firestore location (choose closest to your users)
5. Click "Enable"

### Set Firestore Security Rules

After creating the database, update security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow public read access to content
    match /content/{document} {
      allow read: if true;
      allow write: if false; // Only admin via backend can write
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Step 3: Enable Firebase Storage

1. Click on "Storage" in the left sidebar
2. Click "Get started"
3. Review security rules and click "Next"
4. Select storage location (same as Firestore)
5. Click "Done"

### Set Storage Security Rules

Update storage rules for proper access:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow public read for all files
    match /{allPaths=**} {
      allow read: if true;
      allow write: if false; // Only backend can write
    }
  }
}
```

## Step 4: Get Service Account Credentials

1. Click on the gear icon (⚙️) next to "Project Overview"
2. Select "Project settings"
3. Go to "Service accounts" tab
4. Click "Generate new private key"
5. Click "Generate key" in the confirmation dialog
6. A JSON file will be downloaded - **keep this file secure!**

## Step 5: Get Web App Configuration

1. In Project Settings, go to "General" tab
2. Scroll down to "Your apps" section
3. Click the web icon (`</>`) to add a web app
4. Register app with a nickname: "Vrindopnishad Web"
5. Click "Register app"
6. Copy the `firebaseConfig` object (you'll need `storageBucket` value)

## Step 6: Configure Backend

1. Rename the downloaded JSON file to `firebase-credentials.json`
2. Copy it to `/app/backend/` directory
3. Update `/app/backend/.env` file:

```env
# Replace these values with your Firebase project details
FIREBASE_PROJECT_ID="your-firebase-project-id"
FIREBASE_CREDENTIALS_PATH="/app/backend/firebase-credentials.json"
FIREBASE_STORAGE_BUCKET="your-project-id.appspot.com"
```

Example:
```env
FIREBASE_PROJECT_ID="vrindopnishad-abc123"
FIREBASE_CREDENTIALS_PATH="/app/backend/firebase-credentials.json"
FIREBASE_STORAGE_BUCKET="vrindopnishad-abc123.appspot.com"
```

## Step 7: Restart Backend Server

After updating configuration:

```bash
sudo supervisorctl restart backend
```

Check logs to ensure Firebase initialized successfully:
```bash
tail -n 50 /var/log/supervisor/backend.err.log
```

You should see: "INFO: Application startup complete" without Firebase errors.

## Step 8: Test the Setup

1. Login to admin dashboard: `/admin/login`
   - Email: `admin@vrindopnishad.com`
   - Password: `admin123`

2. Create a test content item
3. Try uploading an image or audio file
4. Try generating AI audio or image
5. View the content on the public pages

## Firestore Collections Structure

The app uses the following Firestore structure:

```
content/
  ├── {contentId1}
  │   ├── id: string
  │   ├── title: string
  │   ├── category: string (shloka|strotra|poem)
  │   ├── description: string
  │   ├── sanskrit_text: string
  │   ├── hindi_text: string
  │   ├── english_text: string
  │   ├── english_translation: string
  │   ├── audio_url: string
  │   ├── image_urls: array
  │   ├── video_urls: array
  │   ├── created_at: timestamp
  │   └── updated_at: timestamp
```

## Storage Structure

Firebase Storage will contain:

```
/
├── audio/
│   └── {contentId}_{uuid}.mp3
├── images/
│   └── {contentId}_{uuid}.png
└── videos/
    └── {contentId}_{uuid}.mp4
```

## Security Best Practices

1. **Never commit** `firebase-credentials.json` to version control
2. Add to `.gitignore`:
   ```
   firebase-credentials.json
   *-credentials.json
   ```
3. Use environment variables for sensitive data
4. Regularly rotate service account keys
5. Monitor Firebase usage in the console
6. Set up billing alerts to avoid unexpected charges

## Troubleshooting

### Error: "Firebase not initialized"
- Check if `firebase-credentials.json` exists in `/app/backend/`
- Verify the file path in `.env` is correct
- Ensure the JSON file is valid (not corrupted)

### Error: "Permission denied" on Firestore/Storage
- Review and update security rules
- Ensure backend is using service account credentials correctly

### Error: "Storage bucket not found"
- Verify `FIREBASE_STORAGE_BUCKET` in `.env` matches your project
- Format should be: `your-project-id.appspot.com`

## Cost Estimates

Firebase free tier includes:
- **Firestore**: 1GB storage, 50K reads/day, 20K writes/day
- **Storage**: 5GB storage, 1GB download/day
- **Authentication**: Unlimited

These limits are sufficient for initial deployment. Monitor usage in Firebase Console.

## Next Steps

After Firebase is configured:
1. Update admin credentials in `.env`:
   ```env
   ADMIN_EMAIL="your-email@example.com"
   ADMIN_PASSWORD="your-secure-password"
   ```

2. Consider adding more admin users by creating an admin management system

3. Customize the app design and content categories as needed

---

**Need Help?**
- Firebase Documentation: https://firebase.google.com/docs
- Firebase Console: https://console.firebase.google.com
- Check backend logs: `tail -f /var/log/supervisor/backend.err.log`
