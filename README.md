IF made chnages on to public stsatic pages:
No need to run "flutter Web build"

firebase deploy --only hosting:safescann-public-static 

# Firebase Hosting Deployment Guide

## 🔧 Prerequisites
- Firebase CLI (`npm install -g firebase-tools`)
- Flutter SDK (for web builds)
- Authenticated with Firebase (`firebase login`)

## 🚀 Deployment Commands

### 1. Full Clean & Deploy (Recommended)
```bash
# Clean build and deploy everything
flutter clean && \
flutter build web --release --web-renderer canvaskit && \
firebase deploy --only hosting