# How to Connect Backend to "santvaanig" Firebase Project

To fully connect your Web and Mobile apps to the same database, you need to configure the Backend with the Admin credentials for the `santvaanig` project.

## Step 1: Get the Service Account Key

1.  Open the **Firebase Console**: [https://console.firebase.google.com/](https://console.firebase.google.com/)
2.  Select the project **santvaanig**.
3.  Click the ⚙️ (Gear icon) next to "Project Overview" and select **Project settings**.
4.  Go to the **Service accounts** tab.
5.  Click **Generate new private key**.
6.  Click **Generate key** to confirm.
7.  A JSON file will download (e.g., `santvaanig-firebase-adminsdk-xxxxx.json`).

## Step 2: Configure the Backend

1.  **Rename** the downloaded file to `firebase-credentials.json`.
2.  **Move** this file into your `backend/` folder:
    `/Users/mr.bajrangi/Vrindopnishad/backend/firebase-credentials.json`
3.  **Update/Create** the `backend/.env` file. Open the file `/Users/mr.bajrangi/Vrindopnishad/backend/.env` and ensure it matches this config:

```env
FIREBASE_PROJECT_ID="santvaanig"
FIREBASE_CREDENTIALS_PATH="./firebase-credentials.json"
FIREBASE_STORAGE_BUCKET="santvaanig.firebasestorage.app"
JWT_SECRET_KEY="vrindopnishad-secret-key-change-this-in-prod"
ADMIN_EMAIL="admin@vrindopnishad.com"
ADMIN_PASSWORD="admin123"
```

## Step 3: Restart the Backend

If the backend is running, stop it (Ctrl+C) and restart it:

```bash
cd backend
source venv/bin/activate
python -m uvicorn server:app --reload --host 0.0.0.0
```

Once this is done, your Web App (Backend API) and Mobile App (Flutter) will both be talking to the `santvaanig` Firebase project!
