# Calendar Sync
This repository contains a code sample from a project I developed for a client, where I created a website for a rental company they were establishing. The showcased code originates from the back-end server, which I implemented in Java.

Due to the commercial nature of the project, I am unable to share the full source code. However, I have obtained permission to present this class, which highlights the calendar synchronization functionality of the project. Please note that certain references to methods and classes are omitted due to these restrictions.

## The Problem
The client managed several properties listed on rental platforms like Airbnb and Vrbo. While these platforms provide valuable visibility, they also take a significant commission on each booking. To maximize profits, the client wanted to create their own website for direct bookings, while still maintaining their listings on Airbnb and Vrbo for increased exposure. The challenge was to develop a system that allowed all three platforms to accept bookings while keeping them synchronized to avoid double bookings.

The first part of the solution, not included here, involved integrating Google Calendar with the Airbnb and Vrbo websites. I created three Google calendars: two synced with Airbnb and Vrbo to capture bookings from those platforms, and a third to manage bookings made through the client’s website. These calendars are interconnected, ensuring that when a booking is made on one platform, the others are updated accordingly.

## Code Overview
This class includes the following methods:

**getEventList** - Connects to Google using the Google Calendar API, retrieves all events from the three calendars, and combines them with any pending bookings into a unified list.

**getCurrentBookings** - Processes the event list to break down start and end dates into individual booked days, providing a comprehensive view of all currently booked dates.

**bookDates** - Handles error checking for incoming booking requests, ensuring that all required fields are completed and that the requested date range is valid and available. If these conditions are met, the booking is placed in a pending queue awaiting payment.

**finalizeBooking** - Once payment is processed, this method removes the booking from the pending queue and updates the calendar with the confirmed booking.

**dateTimeToDateString, reorderDate, stringToDate, diffInDays** - Helper functions that support the service's functionality, primarily by converting between different date formats.
