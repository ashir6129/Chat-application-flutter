#!/bin/bash
# ZyntraPlus — Run with Google Auth enabled
# Usage: bash run_with_google_auth.sh

GOOGLE_SERVER_CLIENT_ID="550799770194-t35c6mptpnh8db2gd1qkr3n1hqv92rto.apps.googleusercontent.com"

# Use local backend on Android emulator (10.0.2.2 maps to host localhost)
# Change to your ngrok URL if testing on a real device with local backend:
# API_BASE_URL="https://profound-friend-implosive.ngrok-free.dev/api/v1"
API_BASE_URL="http://10.0.2.2:4000/api/v1"

echo "🚀 Running ZyntraPlus with Google Auth..."
echo "   Server Client ID: $GOOGLE_SERVER_CLIENT_ID"
echo "   API Base URL:     $API_BASE_URL"
echo ""

flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="$GOOGLE_SERVER_CLIENT_ID" \
  --dart-define=API_BASE_URL="$API_BASE_URL"
