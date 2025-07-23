# Release Notes

## 9.5.0
### New
- SDK version is now displayed on the main screen.
- Added alert for missing config file.
- App only loads virtual visit screens according to Supported Features config field.

## 9.3.0
### New
Added support for SDK version 9.3.0. 
- This includes a phone/virtual visit cancellation button underneath the Resume Visit button when a previous visit has been identified as active. 
- Activating the visit cancellation flow will demonstrate the new UI supporting the new visit cancellation interface which requires a cancellation reason. 

## 9.2.0
### New
This version introduces a new Sample App built in SwiftUI and SPM (Service Package Manager). This is still a work in progress, and some core functionality is missing. The new Sample App includes:
- Creating and resuming a virtual visit (aka Virtual Booking Flow)
- Booking a provider (aka Provider Booking Flow)
- Ability to switch environments (dev/stage/prod)

### Future Improvements:
- Retail Booking Flow (aka Retail Booking Flow)
- New Payment Methods:
    - Credit Card Payment
    - Other Insurance Payment
- Filter supported payment methods based on booking flow.
- Dependant Support
