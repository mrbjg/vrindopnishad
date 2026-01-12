# Project Utilities & Commands

This file defines the common commands used for developing, building, and deploying the different parts of the **Sant-Vaani (Vrindopnishad)** project.

---

## 📱 Mobile App (Flutter)

Located in `mobile_app/`.

### Development
*   **Run on Device/Emulator:**
    ```bash
    cd mobile_app
    flutter run
    ```
*   **Get Dependencies:**
    ```bash
    cd mobile_app
    flutter pub get
    ```
*   **Clean Project (Fixes build errors):**
    ```bash
    cd mobile_app
    flutter clean
    ```

### Building for Production
*   **Build Android APK (Release):**
    ```bash
    cd mobile_app
    flutter build apk --release
    ```
    *Output location:* `build/app/outputs/flutter-apk/app-release.apk`
    *Note: Ensure you have configured `mobile_app/android/key.properties` for a signed production build. See [MOBILE_SIGNING.md](./MOBILE_SIGNING.md) for details.*

*   **Build iOS (Requires Mac):**
    ```bash
    cd mobile_app
    flutter build ios
    ```

*   **Generate App Icons:**
    (If you have changed the icon configuration)
    ```bash
    cd mobile_app
    flutter pub run flutter_launcher_icons
    ```

---

## 🌐 Web Frontend (React)

Located in `frontend/`.

### Development
*   **Start Development Server:**
    ```bash
    cd frontend
    npm start
    ```
    *Access at:* `http://localhost:3000`

*   **Install Dependencies:**
    ```bash
    cd frontend
    npm install
    ```

### Deployment (GitHub Pages)
*   **Deploy to GitHub Pages:**
    This runs the build and pushes to the `gh-pages` branch.
    ```bash
    cd frontend
    npm run deploy
    ```

*   **Build Only (Local Production Build):**
    ```bash
    cd frontend
    npm run build
    ```

---

## 🔥 Backend (Python/FastAPI)

Located in `backend/`.

### Setup & Run
1.  **Activate Virtual Environment:**
    ```bash
    cd backend
    source venv/bin/activate
    ```
2.  **Install Dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
3.  **Run Server:**
    ```bash
    python -m uvicorn server:app --reload --host 0.0.0.0
    ```
    *API Docs:* `http://localhost:8000/docs`

---

## 🛠 Combined Scripts

Convenience scripts located in the root directory.

*   **Start Full Stack (Frontend + Backend):**
    ```bash
    ./start-full.sh
    ```
*   **Run on Emulator:**
    ```bash
    flutter run -d emulator-5554
    ```