# Public Intake Form

This multi-step intake form allows new or existing clients to create rental agreements with events without requiring authentication.

## Overview

The form consists of three steps:
1. **Renting Business** - Client business information (name, EIN, business address)
2. **Property Owner Info** - Property owner details (name, email, property address)
3. **Events** - Up to 14 rental events with dates and event types

## Routes

- `GET /intake` - Redirects to step 1
- `GET /intake/renting_business` - Step 1: Renting Business
- `GET /intake/property_owner` - Step 2: Property Owner Info
- `GET /intake/events` - Step 3: Events
- `PATCH /intake/:step` - Submit each step
- `GET /intake-complete` - Success page

## Features

### Session-Based Storage
- Form data is stored in the session between steps
- Users can navigate back without losing data
- Session is cleared after successful submission

### Find or Create Logic
- Clients are looked up by EIN
- Existing clients will have new agreements added
- New clients are created with the submitted information

### Team Assignment
- All public intake clients are assigned to the STAFF_TEAM_ID
- Ensure `STAFF_TEAM_ID` is set in your environment variables

### Dynamic Event Forms
- Users start with 1 event field
- Can add up to 14 events using the "Add Another Event" button
- Can remove events with the "Remove" button
- Handled by the `intake-events` Stimulus controller

### Data Storage

Fields stored in JSONB `data` column:
- Agreement: `owner_name`, `owner_email` (using `store_accessor`)

Fields in database columns:
- Client: `business_name`, `ein`
- Agreement: `property_address`, `year`, `status`
- Event: `event_type`, `event_date_on`

## Models Updated

### Client
- `creator` is now optional
- Validation skipped when `creator_id` is nil (public intake mode)

### Agreement  
- `creator` is now optional
- Uses `store_accessor :data, :owner_name, :owner_email`
- Accepts nested attributes for events

### Event
- `creator` is now optional
- Validation skipped when `creator_id` is nil (public intake mode)

## Stimulus Controller

**File:** `app/javascript/controllers/intake_events_controller.js`

Manages dynamic event fields:
- Add events (up to 14 max)
- Remove events
- Ensures at least one event remains
- Handles both new and persisted records properly

## Styling

The form uses Tailwind CSS with a clean, modern design that matches the Augusta Planner branding:
- Green color scheme (`bg-green-600`, `text-green-700`, etc.)
- Responsive layout
- Progress indicator showing current step
- Clear form validation messages

## Testing the Form

1. Ensure `STAFF_TEAM_ID` is set in your `.env` or `application.yml`
2. Start your Rails server
3. Navigate to `/intake`
4. Fill out the three-step form
5. Check that Client, Agreement, and Events are created in the database

## Future Enhancements

Potential improvements:
- Email notifications to property owner
- PDF agreement generation
- Event invitation creation and sending
- Add custom event type input field
- Form validation improvements
- Auto-save drafts

