package services;

import Server.Server;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.auth.oauth2.TokenResponse;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.client.util.DateTime;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.calendar.Calendar;
import com.google.api.services.calendar.CalendarScopes;
import com.google.api.services.calendar.model.Event;
import com.google.api.services.calendar.model.EventDateTime;
import com.google.api.services.calendar.model.Events;
import com.google.api.services.gmail.GmailScopes;
import requestResult.PendingBookingRequest;
import requestResult.PostBookingRequest;
import requestResult.PostBookingResult;

import java.io.*;
import java.security.GeneralSecurityException;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;

public class BookingService extends CredentialService {

  protected static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();

  public String[] getCurrentBookings(String id) throws GeneralSecurityException, IOException {

    final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();

    Calendar service =
            new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, getCredentials(HTTP_TRANSPORT))
                    .setApplicationName("Rental Website Testing")
                    .build();

    List<Event> items = getEventList(id, service);
    if(items.isEmpty()) {
      return new String[0];
    }
    ArrayList<String> bookedDays = new ArrayList<>();

    for(Event event : items) {
      String startDate = "";
      String endDate = "";
      if(event.getStart().getDateTime() != null) {
        startDate = dateTimeToDateString(event.getStart().getDateTime());

        endDate = dateTimeToDateString(event.getEnd().getDateTime());
      }
      else {
        startDate = reorderDate(event.getStart().getDate().toString());

        endDate = reorderDate(event.getEnd().getDate().toString());
      }
      Date start = stringToDate(startDate);
      Date end = stringToDate(endDate);

      while (start.before(end)) {
        String date = dateTimeToDateString(new DateTime(start));
        bookedDays.add(date);
        start.setDate(start.getDate() + 1);
      }
      bookedDays.add(endDate);
    }
    String[] finalDateList = new String[bookedDays.size()];
    return bookedDays.toArray(finalDateList);
  }

  public ArrayList<Event> getEventList(String id, Calendar service) {
    ArrayList<Event> eventList = new ArrayList<>();

    PropertyDatabase database = new PropertyDatabase();
    String id1 = database.getCalendarID(Integer.parseInt(id), "airBnB");

    try {
      Events events = service.events().list(id1)
              .setTimeMin(new DateTime(Date.from(Instant.now())))
              .setOrderBy("startTime")
              .setSingleEvents(true)
              .execute();
      eventList.addAll(events.getItems());
    }
    catch (IOException e) {
      Server.serverLog.logp(Level.INFO, "BookingService", "getEventList",
              "Could not connect to AirBnB calendar for property " + id);
    }

    try {
      String id2 = database.getCalendarID(Integer.parseInt(id), "vrbo");
      Events events = service.events().list(id2)
              .setTimeMin(new DateTime(Date.from(Instant.now())))
              .setOrderBy("startTime")
              .setSingleEvents(true)
              .execute();
      eventList.addAll(events.getItems());
    }
    catch (IOException e) {
      Server.serverLog.logp(Level.INFO, "BookingService", "getEventList",
              "Could not connect to Vrbo Calendar for property " + id);
    }

    try {
      String id3 = database.getCalendarID(Integer.parseInt(id), "main");
      Events events = service.events().list(id3)
              .setTimeMin(new DateTime(Date.from(Instant.now())))
              .setOrderBy("startTime")
              .setSingleEvents(true)
              .execute();
      eventList.addAll(events.getItems());
    }
    catch (IOException e) {
      Server.serverLog.logp(Level.INFO, "BookingService", "getEventList",
              "Could not connect to main calendar for property " + id);
    }


    List<PendingBookingRequest> pending = new ArrayList<>(Server.pendingBookings.values());
    for(int i = 0; i < pending.size(); ++i) {
      eventList.add(pending.get(i).getEvent());
    }
    return eventList;
  }

  public static String dateTimeToDateString(DateTime dateTime) {
    StringBuilder dateString = new StringBuilder();
    dateString.append(dateTime.toString());
    return reorderDate(dateString.substring(0,10));
  }
  private static String reorderDate(String oldDate) {
    StringBuilder date = new StringBuilder(oldDate);
    String year = date.substring(0, 4);
    date.delete(0, 5);
    date.append("-" + year);
    return date.toString();
  }

  public static Date stringToDate(String date) {
    int year = Integer.parseInt(date.substring(6,10)) - 1900;
    int month = Integer.parseInt(date.substring(0, 2)) - 1;
    int day = Integer.parseInt(date.substring(3,5));

    return new Date(year, month, day);
  }

  public static int diffInDays(Date startDate, Date endDate) {
    long diffInMill = Math.abs(endDate.getTime() - startDate.getTime());
    return (int) TimeUnit.DAYS.convert(diffInMill, TimeUnit.MILLISECONDS);
  }

  public PostBookingResult bookDates(String id, PostBookingRequest request) throws GeneralSecurityException, IOException{

    if(request.getStartDate() == null || request.getEndDate() == null || request.getName() == null ||
            request.getPhone() == null || request.getEmail() == null) {
      return new PostBookingResult(false, "All fields are required", null);
    }

    PropertyDatabase database = new PropertyDatabase();

    String startDate = request.getStartDate();
    String endDate = request.getEndDate();

    Date start = stringToDate(startDate);

    Date end = stringToDate(endDate);

    if(start.before(Date.from(Instant.now())) || end.before(Date.from(Instant.now()))) {
      return new PostBookingResult(false, "Start or End date is before current date", null);
    }
    if(end.before(start)) {
      return new PostBookingResult(false, "End date takes place before start date", null);
    }

    String[] bookings = getCurrentBookings(id);
    for(int i = 0; i < bookings.length; ++i) {
      Date date = stringToDate(bookings[i]);
      if(date.after(start) && date.before(end)) {
        return new PostBookingResult(false, "A date between your start and end dates was booked", null);
      }
    }

    Event event = new Event().setSummary(request.getName())
            .setDescription("Email: " + request.getEmail() + "\nPhone #:" + request.getPhone());
    EventDateTime finalStart = new EventDateTime().setDateTime(new DateTime(start)).setTimeZone("America/Denver");
    EventDateTime finalEnd = new EventDateTime().setDateTime(new DateTime(end)).setTimeZone("America/Denver");
    event.setStart(finalStart).setEnd(finalEnd);
    String requestID = UUID.randomUUID().toString();
    PendingBookingRequest pendingRequest = new PendingBookingRequest(event, database.getCalendarID(Integer.parseInt(id), "main"),
            request.getEmail(), request.getPhone(), Integer.parseInt(id));
    Server.pendingBookings.put(requestID, pendingRequest);
    return new PostBookingResult(true, null, requestID);
  }

  public boolean finalizeBooking(String id) {
    try {
      final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
      Calendar service =
            new Calendar.Builder(HTTP_TRANSPORT, JSON_FACTORY, getCredentials(HTTP_TRANSPORT))
                    .setApplicationName("Rental Website Testing")
                    .build();
      PendingBookingRequest request = Server.pendingBookings.get(id);
      service.events().insert(request.getCalendarID(), request.getEvent()).execute();
      Server.pendingBookings.remove(id);
      MessageService messageService = new MessageService();
      messageService.sendConfirmationEmail(request);
      return true;
    }
    catch (Exception e) {
      e.printStackTrace();
      return false;
    }
  }
}
