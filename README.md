# Operations Technology Support

A demo-safe, responsive Help Desk for restaurant technology. It contains the public Crew/Manager Help Desk, a private technician dashboard, a simple day planner, resolution capture, and a local mocked **Gus • Apprentice**.

## Run locally

No package install is required. Open `index.html` in a browser, or serve this folder with any basic local web server.

The public Help Desk submits new ticket details to the connected Supabase project. Browser storage still keeps the newest request available for the Technician demo screen. Optional JPG, PNG, and WebP photos (up to 5 MB each) upload to a private Supabase bucket; they have no public link and are not readable from the Crew/Manager screen.

## Edit Help Desk choices

In Supabase's **Table Editor**, open `affected_areas` or `technology_systems`. Add, rename, reorder with `display_order`, or set `active` to off to hide an option from the public form. Existing tickets keep the original wording they were submitted with.

## Demo flow (3–5 minutes)

1. Start on **Help Desk**. Explain that crew sees guided troubleshooting, not AI. Select the payment terminal scenario, add a short issue, and continue.
2. Check the safe steps and submit. Point out that the request is now securely saved to the Help Desk database, while the public site cannot read anyone's tickets.
3. Switch to **Technician**. Show the priority-based planned route, field stops, open cases, and status overview.
4. Highlight **Gus • Apprentice**: use the four assistance buttons. Explain it is only available in the private technician workspace and is mocked locally today.
5. Open the active case and enter a verified resolution. Select **Verify resolution & teach Gus**. Back on the dashboard, show it in “Recently learned.”
6. Close by describing the future AI boundary: the `assist()` function is the provider seam. It currently runs deterministic local demo logic; a self-hosted Ollama adapter can replace it later without sending operational data to a third-party AI service.

## Privacy and next steps

All restaurant names, people, and cases are fictional. The Help Desk uses Supabase only for ticket storage; it sends no data to any AI provider. Row Level Security allows public visitors to submit a ticket but not read tickets, technician notes, resolutions, or private attachments. The public browser key is limited by those rules; a Supabase service-role key must never be placed in this website.

The technician-side AI remains a deterministic local prototype. A self-hosted Ollama adapter can later replace the `LocalDemoProvider` without sending operational data to a third-party AI service.
