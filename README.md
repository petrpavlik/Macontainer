# Macontainer

A native desktop macOS app that provides graphical interface for [Apple's Container CLI](https://github.com/apple/container).

<img width="1081" alt="Screenshot 2025-06-28 at 11 46 28" src="https://github.com/user-attachments/assets/f2a43e3b-e5aa-4b05-a50e-51272ee642b8" />

## Features

### Container Management
- **View all containers** - List all containers with their status, image, OS, architecture, and network addresses
- **Start/Stop/Kill containers** - Control container lifecycle with simple button clicks
- **Bulk operations** - Select multiple containers and perform operations on them simultaneously
- **Real-time status updates** - Container states update automatically
- **Delete containers** - Remove individual containers or delete all containers at once

### Image Management
- **Browse container images** - View all available container images with names, tags, and digests
- **Delete images** - Remove individual images or delete all images at once
- **Bulk image operations** - Select multiple images for batch deletion
- **Prune unused images** - Clean up dangling and unused images to free up disk space

### System Control
- **Container system management** - Start and stop the container system daemon
- **Auto-launch support** - Optionally start the container system when the app launches
- **Auto-quit support** - Optionally stop containers when the app quits
- **System status monitoring** - Real-time indication of whether the container system is running

### User Experience
- **Native macOS interface** - Built with SwiftUI for a modern, responsive user experience
- **Update notifications** - Automatic checking for newer versions of the Container CLI

## Installation

- Grab the latest DMG from releases section and install Macontainer.
- Clone the repo and build from the source code.

## Known Issues
- First launch of the CLI may require user input and hang the app when pressing the start button.
- Stopping the syste with running containers may cause the CLI to hang. Waiting for Apple to fix this.
