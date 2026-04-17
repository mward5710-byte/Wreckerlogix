# WreckerLogix

**AI-Powered Tow Industry Operations Platform**

WreckerLogix is a comprehensive mobile and desktop application built for the towing and recovery industry. It streamlines dispatch operations, driver management, documentation, and accounting into a single intelligent platform.

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (Dart) |
| Platforms | iOS, Android, Windows, macOS, Linux |
| State Management | TBD |
| Backend | TBD |
| Database | TBD |

> **Why Flutter?** Single codebase for mobile AND desktop. Office staff use Windows desktops while drivers use phones  Flutter handles both from one codebase with native performance.
>
> ---
>
> ## Core Modules
>
> ### Dispatch Workflow (`src/dispatch/`)
> - Intelligent job assignment and routing
> - - Real-time job status tracking
>   - - Customer notification system
>     - - Priority queue management
>      
>       - ### Voice Command Engine (`src/voice-commands/`)
>       - - Hands-free operation for drivers
>         - - Natural language job updates
>           - - Voice-activated status changes
>             - - Text-to-speech feedback
>              
>               - ### GPS Integration (`src/gps/`)
>               - - Real-time fleet tracking
>                 - - Route optimization for tow vehicles
>                   - - Geofencing for service areas
>                     - - ETA calculations
>                      
>                       - ### Photo Documentation (`src/photo-docs/`)
>                       - - Vehicle condition capture (before/after)
>                         - - Timestamped and geotagged photos
>                           - - Damage documentation workflow
>                             - - Insurance-ready report generation
>                              
>                               - ### Time Tracking (`src/time-tracking/`)
>                               - - Driver shift management
>                                 - - Per-job time logging
>                                   - - Overtime calculations
>                                     - - Payroll-ready exports
>                                      
>                                       - ### Accounting (`src/accounting/`)
>                                       - - Invoice generation
>                                         - - Payment processing
>                                           - - Revenue tracking and reporting
>                                             - - Expense management
>                                              
>                                               - ---
>
> ## Project Structure
>
> ```
> Wreckerlogix/
>  README.md
>  .gitignore
>  src/
>      dispatch/          # Dispatch Workflow
>      voice-commands/    # Voice Command Engine
>      gps/               # GPS Integration
>      photo-docs/        # Photo Documentation
>      time-tracking/     # Time Tracking
>      accounting/        # Accounting
> ```
>
> ---
>
> ## Getting Started
>
> ### Prerequisites
> - [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable)
> - - Dart SDK (bundled with Flutter)
>   - - Android Studio or VS Code with Flutter extension
>     - - Xcode (for iOS builds, macOS only)
>      
>       - ### Setup
>       - ```bash
>         # Clone the repository
>         git clone https://github.com/mward5710-byte/Wreckerlogix.git
>         cd Wreckerlogix
>
>         # Install dependencies (once Flutter project is initialized)
>         flutter pub get
>
>         # Run on connected device or emulator
>         flutter run
>
>         # Run on desktop
>         flutter run -d windows
>         flutter run -d macos
>         flutter run -d linux
>         ```
>
> ---
>
> ## License
>
> Proprietary - All rights reserved.
> 
