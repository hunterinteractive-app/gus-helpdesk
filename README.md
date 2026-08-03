# Gus prototype

A demo-safe, responsive local prototype for an Operations Technology Professional. It contains a crew/manager Help Desk, a private technician dashboard, a simple day planner, resolution capture, and a local mocked **Gus • Apprentice**.

## Run locally

No package install or cloud account is required. Open `index.html` in a browser, or serve this folder with any basic local web server. The app uses browser `localStorage` only; clearing site data resets the demo.

## Demo flow (3–5 minutes)

1. Start on **Help Desk**. Explain that crew sees guided troubleshooting, not AI. Select the payment terminal scenario, add a short issue, and continue.
2. Check the three safe steps and submit. Point out the clear ticket ID and that the flow captures useful context before escalation.
3. Switch to **Technician**. Show the priority-based planned route, field stops, open cases, and status overview.
4. Highlight **Gus • Apprentice**: use the four assistance buttons. Explain it is only available in the private technician workspace and is mocked locally today.
5. Open the active case and enter a verified resolution. Select **Verify resolution & teach Gus**. Back on the dashboard, show it in “Recently learned.”
6. Close by describing the future AI boundary: the `assist()` function is the provider seam. It currently runs deterministic local demo logic; a self-hosted Ollama adapter can replace it later without sending operational data to a third-party AI service.

## Privacy and next steps

All restaurant names, people, and cases are fictional. This prototype makes no network calls and contains no third-party AI integration. A production version can retain the same UI while adding Supabase authentication/storage and an `AIProvider` interface backed by an on-premise or self-hosted Ollama service.
