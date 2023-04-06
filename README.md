# Boutique-CloudSyncSession-Example
This is my sample project that smushes [@mergesort's excellent Boutique framework](https://github.com/mergesort/Boutique) with [@RyanAshcraft's excellent CloudSyncSession framework](https://github.com/ryanashcraft/CloudSyncSession)

Non-code things:
1. Add Capabilities - iCloud (with CloudKit selected + a container), Background Modes (with Background fetch and Remote notifications selected)
2. Set up the CloudKit container with the desired record types ("Item" in this project), zones ("ItemZone"), and subscriptions ("ItemZoneSubscription")

*Note: as it stands, I haven't hooked up delete or conflict resolution yet.*

In action:
[![Watch the video](https://files.mastodon.social/media_attachments/files/110/152/671/838/681/163/small/8f14ca2fa489d593.png])(https://files.mastodon.social/media_attachments/files/110/152/671/838/681/163/original/8f14ca2fa489d593.mp4)
