Architecture case study

A walk-through of a Flutter app that implements the MVVM architectural pattern.

The code examples in this guide are from the Compass sample application, an app that helps users build and book itineraries for trips. It's a robust sample application with many features, routes, and screens. The app communicates with an HTTP server, has development and production environments, includes brand-specific styling, and contains high test coverage. In these ways and more, it simulates a real-world, feature-rich Flutter application. 

 The Compass app's architecture most resembles the MVVM architectural pattern as described in Flutter's app architecture guidelines. This architecture case study demonstrates how to implement those guidelines by walking through the "Home" feature of the compass app. If you aren't familiar with MVVM, you should read those guidelines first.

The Home screen of the Compass app displays user account information and a list of the user's saved trips. From this screen you can log out, open detailed trip pages, delete saved trips, and navigate to the first page of the core app flow, which allows the user to build a new itinerary.

In this case study, you'll learn the following:

    How to implement Flutter's app architecture guidelines using repositories and services in the data layer and the MVVM architectural pattern in the UI layer
    How to use the Command pattern to safely render UI as data changes
    How to use ChangeNotifier and Listenable objects to manage state
    How to implement Dependency Injection using package:provider
    How to set up tests when following the recommended architecture
    Effective package structure for large Flutter apps

This case-study was written to be read in order. Any given page might reference the previous pages.

The code examples in this case-study include all the details needed to understand the architecture, but they're not complete, runnable snippets. If you prefer to follow along with the full app, you can find it on GitHub.
Package structure

Well-organized code is easier for multiple engineers to work on with minimal code conflicts and is easier for new engineers to navigate and understand. Code organization both benefits and benefits from well-defined architecture.

There are two popular means of organizing code:

    By feature - The classes needed for each feature are grouped together. For example, you might have an auth directory, which would contain files like auth_viewmodel.dart, login_usecase.dart, logout_usecase.dart, login_screen.dart, logout_button.dart, etc.
    By type - Each "type" of architecture is grouped together. For example, you might have directories such as repositories, models, services, and viewmodels.

The architecture recommended in this guide lends itself to a combination of the two. Data layer objects (repositories and services) aren't tied to a single feature, while UI layer objects (views and view models) are. The following is how the code is organized within the Compass application.

    lib/
        ui/
            core/
                ui/
                    <shared_widgets>
                themes/
            <feature_name>/
                view_models/
                    <view_model_class>.dart
                widgets/
                    <feature_name>_screen.dart
                    <other_widgets>
        domain/
            models/
                <model_name>.dart
        data/
            repositories/
                <repository_class>.dart
            services/
                <service_class>.dart
            model/
                <api_model_class>.dart
        config/
        utils/
        routing/
        main_staging.dart
        main_development.dart
        main.dart
    test/// Contains unit and widget tests.
        data/
        domain/
        ui/
        utils/
    testing/// Contains mocks that other classes need to execute tests.
        fakes/
        models/

Most of the application code lives in the data, domain, and ui folders. The data folder organizes code by type, because repositories and services can be used across different features and by multiple view models. The ui folder organizes the code by feature, because each feature has exactly one view and exactly one view model.

Other notable features of this folder structure:

    The UI folder also contains a subdirectory named "core". Core contains widgets and theme logic that is shared by multiple views, such as buttons with your brand styling.
    The domain folder contains the application data types, because they're used by the data and ui layers.
    The app contains three "main" files, which act as different entry points to the application for development, staging, and production.
    There are two test-related directories at the same level as lib: test/ has the test code, and its own structure matches lib/. testing/ is a subpackage that contains mocks and other testing utilities which can be used in other packages' test code. The testing/ folder could be described as a version of your app that you don't ship. It's the content that is tested.

There's additional code in the compass app that doesn't pertain to architecture. For the full package structure, view it on GitHub.
Other architecture options

The example in this case-study demonstrates how one application abides by our recommended architectural rules, but there are many other example apps that could've been written. The UI of this app leans heavily on view models and ChangeNotifier, but it could've easily been written with streams, or with other libraries such as riverpod, flutter_bloc, and signals. The communication between layers of this app handled everything with method calls, including polling for new data. It could've instead used streams to expose data from a repository to a view model and still abide by the rules covered in this guide.

Even if you do follow this guide exactly, and choose not to introduce additional libraries, you have decisions to make: Will you have a domain layer? If so, how will you manage data access? The answer depends so much on an individual team's needs that there isn't a single right answer. Regardless of how you answer these questions, the principles in this guide will help you write scalable Flutter apps.

And if you squint, aren't all architectures MVVM anyway?

UI layer case study

A walk-through of the UI layer of an app that implements MVVM architecture.

The UI layer of each feature in your Flutter application should be made up of two components: a View and a ViewModel.

A screenshot of the booking screen of the compass app.

In the most general sense, view models manage UI state, and views display UI state. Views and view models have a one-to-one relationship; for each view, there's exactly one corresponding view model that manages that view's state. Each pair of view and view model make up the UI for a single feature. For example, an app might have classes called LogOutView and a LogOutViewModel.
Define a view model

A view model is a Dart class responsible for handling UI logic. View models take domain data models as input and expose that data as UI state to their corresponding views. They encapsulate logic that the view can attach to event handlers, like button presses, and manage sending these events to the data layer of the app, where data changes happen.

The following code snippet is a class declaration for a view model class called the HomeViewModel. Its inputs are the repositories that provide its data. In this case, the view model is dependent on the BookingRepository and UserRepository as arguments.
home_viewmodel.dart

class HomeViewModel {
  HomeViewModel({
    required BookingRepository bookingRepository,
    required UserRepository userRepository,
  }) :
    // Repositories are manually assigned because they're private members.
    _bookingRepository = bookingRepository,
    _userRepository = userRepository;

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;
  // ...
}

View models are always dependent on data repositories, which are provided as arguments to the view model's constructor. View models and repositories have a many-to-many relationship, and most view models will depend on multiple repositories.

As in the earlier HomeViewModel example declaration, repositories should be private members on the view model, otherwise views would have direct access to the data layer of the application.
UI state

The output of a view model is data that a view needs to render, generally referred to as UI State, or just state. UI state is an immutable snapshot of data that is required to fully render a view.

A screenshot of the booking screen of the compass app.

The view model exposes state as public members. On the view model in the following code example, the exposed data is a User object, as well as the user's saved itineraries which are exposed as an object of type List<BookingSummary>.
home_viewmodel.dart

class HomeViewModel {
  HomeViewModel({
   required BookingRepository bookingRepository,
   required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
      _userRepository = userRepository;

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;

  User? _user;
  User? get user => _user;

  List<BookingSummary> _bookings = [];

  /// Items in an [UnmodifiableListView] can't be directly modified,
  /// but changes in the source list can be modified. Since _bookings
  /// is private and bookings is not, the view has no way to modify the
  /// list directly.
  UnmodifiableListView<BookingSummary> get bookings => UnmodifiableListView(_bookings);

  // ...
}

As mentioned, the UI state should be immutable. This is a crucial part of bug-free software.

The compass app uses the package:freezed to enforce immutability on data classes. For example, the following code shows the User class definition. freezed provides deep immutability, and generates the implementation for useful methods like copyWith and toJson.
user.dart

@freezed
class User with _$User {
  const factory User({
    /// The user's name.
    required String name,

    /// The user's picture URL.
    required String picture,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

Note

In the view model example, two objects are needed to render the view. As the UI state for any given model grows in complexity, a view model might have many more pieces of data from many more repositories exposed to the view. In some cases, you might want to create objects that specifically represent the UI state. For example, you could create a class named HomeUiState.
Updating UI state

In addition to storing state, view models need to tell Flutter to re-render views when the data layer provides a new state. In the Compass app, view models extend ChangeNotifier to achieve this.
home_viewmodel.dart

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
   required BookingRepository bookingRepository,
   required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
      _userRepository = userRepository;
  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;

  User? _user;
  User? get user => _user;

  List<BookingSummary> _bookings = [];
  List<BookingSummary> get bookings => _bookings;

  // ...
}

HomeViewModel.user is a public member that the view depends on. When new data flows from the data layer and new state needs to be emitted, notifyListeners is called.

A screenshot of the booking screen of the compass app.

This figure shows from a high-level how new data in the repository propagates up to the UI layer and triggers a re-build of your Flutter widgets.

    New state is provided to the view model from a Repository.
    The view model updates its UI state to reflect the new data.
    ViewModel.notifyListeners is called, alerting the View of new UI State.
    The view (widget) re-renders.

For example, when the user navigates to the Home screen and the view model is created, the _load method is called. Until this method completes, the UI state is empty, the view displays a loading indicator. When the _load method completes, if it's successful, there's new data in the view model, and it must notify the view that new data is available.
home_viewmodel.dart

class HomeViewModel extends ChangeNotifier {
  // ...

 Future<Result> _load() async {
    try {
      final userResult = await _userRepository.getUser();
      switch (userResult) {
        case Ok<User>():
          _user = userResult.value;
          _log.fine('Loaded user');
        case Error<User>():
          _log.warning('Failed to load user', userResult.error);
      }

      // ...

      return userResult;
    } finally {
      notifyListeners();
    }
  }
}

Note

ChangeNotifier and ListenableBuilder (discussed later on this page) are part of the Flutter SDK, and provide a good solution for updating the UI when state changes. You can also use a robust third-party state management solution, such as package:riverpod, package:flutter_bloc, or package:signals. These libraries offer different tools for handling UI updates. Read more about using ChangeNotifier in our state-management documentation.
Define a view

A view is a widget within your app. Often, a view represents one screen in your app that has its own route and includes a Scaffold at the top of the widget subtree, such as the HomeScreen, but this isn't always the case.

Sometimes a view is a single UI element that encapsulates functionality that needs to be re-used throughout the app. For example, the Compass app has a view called LogoutButton, which can be dropped anywhere in the widget tree that a user might expect to find a logout button. The LogoutButton view has its own view model called LogoutViewModel. And on larger screens, there might be multiple views on screen that would take up the full screen on mobile.
Note

"View" is an abstract term, and one view doesn't equal one widget. Widgets are composable, and several can be combined to create one view. Therefore, view models don't have a one-to-one relationship with widgets, but rather a one-to-one relation with a collection of widgets.

The widgets within a view have three responsibilities:

    They display the data properties from the view model.
    They listen for updates from the view model and re-render when new data is available.
    They attach callbacks from the view model to event handlers, if applicable.

A diagram showing a view's relationship to a view model.

Continuing the Home feature example, the following code shows the definition of the HomeScreen view.
home_screen.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
}

Most of the time, a view's only inputs should be a key, which all Flutter widgets take as an optional argument, and the view's corresponding view model.
Display UI data in a view

A view depends on a view model for its state. In the Compass app, the view model is passed in as an argument in the view's constructor. The following example code snippet is from the HomeScreen widget.
home_screen.dart

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // ...
  }
}

Within the widget, you can access the passed-in bookings from the viewModel. In the following code, the booking property is being provided to a sub-widget.
home_screen.dart

@override
  Widget build(BuildContext context) {
    return Scaffold(
      // Some code was removed for brevity.
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(...),
                SliverList.builder(
                   itemCount: viewModel.bookings.length,
                    itemBuilder: (_, index) => _Booking(
                      key: ValueKey(viewModel.bookings[index].id),
                      booking:viewModel.bookings[index],
                      onTap: () => context.push(Routes.bookingWithId(
                         viewModel.bookings[index].id)),
                      onDismissed: (_) => viewModel.deleteBooking.execute(
                           viewModel.bookings[index].id,
                         ),
                    ),
                ),
              ],
            );
          },
        ),
      ),

Update the UI

The HomeScreen widget listens for updates from the view model with the ListenableBuilder widget. Everything in the widget subtree under the ListenableBuilder widget re-renders when the provided Listenable changes. In this case, the provided Listenable is the view model. Recall that the view model is of type ChangeNotifier which is a subtype of the Listenable type.
home_screen.dart

@override
Widget build(BuildContext context) {
  return Scaffold(
    // Some code was removed for brevity.
      body: SafeArea(
        child: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(),
                SliverList.builder(
                  itemCount: viewModel.bookings.length,
                  itemBuilder: (_, index) =>
                      _Booking(
                        key: ValueKey(viewModel.bookings[index].id),
                        booking: viewModel.bookings[index],
                        onTap: () =>
                            context.push(Routes.bookingWithId(
                                viewModel.bookings[index].id)
                            ),
                        onDismissed: (_) =>
                            viewModel.deleteBooking.execute(
                              viewModel.bookings[index].id,
                            ),
                      ),
                ),
              ],
            );
          }
        )
      )
  );
}

Handling user events

Finally, a view needs to listen for events from users, so the view model can handle those events. This is achieved by exposing a callback method on the view model class which encapsulates all the logic.

A diagram showing a view's relationship to a view model.

On the HomeScreen, users can delete previously booked events by swiping a Dismissible widget.

Recall this code from the previous snippet:
A clip that demonstrates the 'dismissible' functionality of the Compass app.
home_screen.dart

SliverList.builder(
  itemCount: widget.viewModel.bookings.length,
  itemBuilder: (_, index) => _Booking(
    key: ValueKey(viewModel.bookings[index].id),
    booking: viewModel.bookings[index],
    onTap: () => context.push(
      Routes.bookingWithId(viewModel.bookings[index].id)
    ),
    onDismissed: (_) =>
      viewModel.deleteBooking.execute(widget.viewModel.bookings[index].id),
  ),
),

On the HomeScreen, a user's saved trip is represented by the _Booking widget. When a _Booking is dismissed, the viewModel.deleteBooking method is executed.

A saved booking is application state that persists beyond a session or the lifetime of a view, and only repositories should modify such application state. So, the HomeViewModel.deleteBooking method turns around and calls a method exposed by a repository in the data layer, as shown in the following code snippet.
home_viewmodel.dart

Future<Result<void>> _deleteBooking(int id) async {
  try {
    final resultDelete = await _bookingRepository.delete(id);
    switch (resultDelete) {
      case Ok<void>():
        _log.fine('Deleted booking $id');
      case Error<void>():
        _log.warning('Failed to delete booking $id', resultDelete.error);
        return resultDelete;
    }

    // Some code was omitted for brevity.
    // final  resultLoadBookings = ...;

    return resultLoadBookings;
  } finally {
    notifyListeners();
  }
}

In the Compass app, these methods that handle user events are called commands.
Command objects

Commands are responsible for the interaction that starts in the UI layer and flows back to the data layer. In this app specifically, a Command is also a type that helps update the UI safely, regardless of the response time or contents.

The Command class wraps a method and helps handle the different states of that method, such as running, complete, and error. These states make it easy to display different UI, like loading indicators when Command.running is true.

The following is code from the Command class. Some code has been omitted for demo purposes.
command.dart

abstract class Command<T> extends ChangeNotifier {
  Command();
  bool running = false;
  Result<T>? _result;

  /// true if action completed with error
  bool get error => _result is Error;

  /// true if action completed successfully
  bool get completed => _result is Ok;

  /// Internal execute implementation
  Future<void> _execute(action) async {
    if (_running) return;

    // Emit running state - e.g. button shows loading state
    _running = true;
    _result = null;
    notifyListeners();

    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

The Command class itself extends ChangeNotifier, and within the method Command.execute, notifyListeners is called multiple times. This allows the view to handle different states with very little logic, which you'll see an example of later on this page.

You may have also noticed that Command is an abstract class. It's implemented by concrete classes such as Command0 Command1. The integer in the class name refers to the number of arguments that the underlying method expects. You can see examples of these implementation classes in the Compass app's utils directory.
Package recommendation

Instead of writing your own Command class, consider using the flutter_command package, which is a robust library that implements classes like these.
Ensuring views can render before data exists

In view model classes, commands are created in the constructor.
home_viewmodel.dart

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
   required BookingRepository bookingRepository,
   required UserRepository userRepository,
  }) : _bookingRepository = bookingRepository,
      _userRepository = userRepository {
    // Load required data when this screen is built.
    load = Command0(_load)..execute();
    deleteBooking = Command1(_deleteBooking);
  }

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;

  late Command0 load;
  late Command1<void, int> deleteBooking;

  User? _user;
  User? get user => _user;

  List<BookingSummary> _bookings = [];
  List<BookingSummary> get bookings => _bookings;

  Future<Result> _load() async {
    // ...
  }

  Future<Result<void>> _deleteBooking(int id) async {
    // ...
  }

  // ...
}

The Command.execute method is asynchronous, so it can't guarantee that the data will be available when the view wants to render. This gets at why the Compass app uses Commands. In the view's Widget.build method, the command is used to conditionally render different widgets.
home_screen.dart

// ...
child: ListenableBuilder(
  listenable: viewModel.load,
  builder: (context, child) {
    if (viewModel.load.running) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.load.error) {
      return ErrorIndicator(
        title: AppLocalization.of(context).errorWhileLoadingHome,
        label: AppLocalization.of(context).tryAgain,
          onPressed: viewModel.load.execute,
        );
     }

    // The command has completed without error.
    // Return the main view widget.
    return child!;
  },
),

// ...

Because the load command is a property that exists on the view model rather than something ephemeral, it doesn't matter when the load method is called or when it resolves. For example, if the load command resolves before the HomeScreen widget was even created, it isn't a problem because the Command object still exists, and exposes the correct state.

This pattern standardizes how common UI problems are solved in the app, making your codebase less error-prone and more scalable, but it's not a pattern that every app will want to implement. Whether you want to use it is highly dependent on other architectural choices you make. Many libraries that help you manage state have their own tools to solve these problems. For example, if you were to use streams and StreamBuilders in your app, the AsyncSnapshot classes provided by Flutter have this functionality built in. 

Data layer

A walk-through of the data layer of an app that implements MVVM architecture.

The data layer of an application, known as the model in MVVM terminology, is the source of truth for all application data. As the source of truth, it's the only place that application data should be updated.

It's responsible for consuming data from various external APIs, exposing that data to the UI, handling events from the UI that require data to be updated, and sending update requests to those external APIs as needed.

The data layer in this guide has two main components, repositories and services.

A diagram that highlights the data layer components of an application.

    Repositories are the source of the truth for application data, and contain logic that relates to that data, like updating the data in response to new user events or polling for data from services. Repositories are responsible for synchronizing the data when offline capabilities are supported, managing retry logic, and caching data.
    Services are stateless Dart classes that interact with APIs, like HTTP servers and platform plugins. Any data that your application needs that isn't created inside the application code itself should be fetched from within service classes.

Define a service

A service class is the least ambiguous of all the architecture components. It's stateless, and its functions don't have side effects. Its only job is to wrap an external API. There's generally one service class per data source, such as a client HTTP server or a platform plugin.

A diagram that shows the inputs and outputs of service objects.

In the Compass app, for example, there's an APIClient service that handles the CRUD calls to the client-facing server.
api_client.dart

class ApiClient {
  // Some code omitted for demo purposes.

  Future<Result<List<ContinentApiModel>>> getContinents() async { /* ... */ }

  Future<Result<List<DestinationApiModel>>> getDestinations() async { /* ... */ }

  Future<Result<List<ActivityApiModel>>> getActivityByDestination(String ref) async { /* ... */ }

  Future<Result<List<BookingApiModel>>> getBookings() async { /* ... */ }

  Future<Result<BookingApiModel>> getBooking(int id) async { /* ... */ }

  Future<Result<BookingApiModel>> postBooking(BookingApiModel booking) async { /* ... */ }

  Future<Result<void>> deleteBooking(int id) async { /* ... */ }

  Future<Result<UserApiModel>> getUser() async { /* ... */ }
}

The service itself is a class, where each method wraps a different API endpoint and exposes asynchronous response objects. Continuing the earlier example of deleting a saved booking, the deleteBooking method returns a Future<Result<void>>.
Note

Some methods return data classes that are specifically for raw data from the API, such as the BookingApiModel class. As you'll soon see, repositories extract data and expose it in a different format.
Define a repository

A repository's sole responsibility is to manage application data. A repository is the source of truth for a single type of application data, and it should be the only place where that data type is mutated. The repository is responsible for polling new data from external sources, handling retry logic, managing cached data, and transforming raw data into domain models.

A diagram that highlights the repository component of an application.

You should have a separate repository for each different type of data in your application. For example, the Compass app has repositories called UserRepository, BookingRepository, AuthRepository, DestinationRepository, and more.

The following example is the BookingRepository from the Compass app, and shows the basic structure of a repository.
booking_repository_remote.dart

class BookingRepositoryRemote implements BookingRepository {
  BookingRepositoryRemote({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  List<Destination>? _cachedDestinations;

  Future<Result<void>> createBooking(Booking booking) async {...}
  Future<Result<Booking>> getBooking(int id) async {...}
  Future<Result<List<BookingSummary>>> getBookingsList() async {...}
  Future<Result<void>> delete(int id) async {...}
}

Development versus staging environments

The class in the previous example is BookingRepositoryRemote, which extends an abstract class called BookingRepository. This base class is used to create repositories for different environments. For example, the compass app also has a class called BookingRepositoryLocal, which is used for local development.

You can see the differences between the BookingRepository classes on GitHub.

The BookingRepository takes the ApiClient service as an input, which it uses to get and update the raw data from the server. It's important that the service is a private member, so that the UI layer can't bypass the repository and call a service directly.

With the ApiClient service, the repository can poll for updates to a user's saved bookings that might happen on the server, and make POST requests to delete saved bookings.

The raw data that a repository transforms into application models can come from multiple sources and multiple services, and therefore repositories and services have a many-to-many relationship. A service can be used by any number of repositories, and a repository can use more than one service.

A diagram that highlights the data layer components of an application.
Domain models

The BookingRepository outputs Booking and BookingSummary objects, which are domain models. All repositories output corresponding domain models. These data models differ from API models in that they only contain the data needed by the rest of the app. API models contain raw data that often needs to be filtered, combined, or deleted to be useful to the app's view models. The repo refines the raw data and outputs it as domain models.

In the example app, domain models are exposed through return values on methods like BookingRepository.getBooking. The getBooking method is responsible for getting the raw data from the ApiClient service, and transforming it into a Booking object. It does this by combining data from multiple service endpoints.
booking_repository_remote.dart

// This method was edited for brevity.
Future<Result<Booking>> getBooking(int id) async {
  try {
    // Get the booking by ID from server.
    final resultBooking = await _apiClient.getBooking(id);
    if (resultBooking is Error<BookingApiModel>) {
      return Result.error(resultBooking.error);
    }
    final booking = resultBooking.asOk.value;

    final destination = _apiClient.getDestination(booking.destinationRef);
    final activities = _apiClient.getActivitiesForBooking(
            booking.activitiesRef);

    return Result.ok(
      Booking(
        startDate: booking.startDate,
        endDate: booking.endDate,
        destination: destination,
        activity: activities,
      ),
    );
  } on Exception catch (e) {
    return Result.error(e);
  }
}

Note

In the Compass app, service classes return Result objects. Result is a utility class that wraps asynchronous calls and makes it easier to handle errors and manage UI state that relies on asynchronous calls.

This pattern is a recommendation, but not a requirement. The architecture recommended in this guide can be implemented without it.

You can learn about this class in the Result cookbook recipe.
Complete the event cycle

Throughout this page, you've seen how a user can delete a saved booking, starting with an event—a user swiping on a Dismissible widget. The view model handles that event by delegating the actual data mutation to the BookingRepository. The following snippet shows the BookingRepository.deleteBooking method.
booking_repository_remote.dart

Future<Result<void>> delete(int id) async {
  try {
    return _apiClient.deleteBooking(id);
  } on Exception catch (e) {
    return Result.error(e);
  }
}

The repository sends a POST request to the API client with the _apiClient.deleteBooking method, and returns a Result. The HomeViewModel consumes the Result and the data it contains, then ultimately calls notifyListeners, completing the cycle. 

Communicating between layers

How to implement dependency injection to communicate between MVVM layers.

Along with defining clear responsibilities for each component of the architecture, it's important to consider how the components communicate. This refers to both the rules that dictate communication, and the technical implementation of how components communicate. An app's architecture should answer the following questions:

    Which components are allowed to communicate with which other components (including components of the same type)?
    What do these components expose as output to each other?
    How is any given layer 'wired up' to another layer?

A diagram showing the components of app architecture.

Using this diagram as a guide, the rules of engagement are as follows:
Component	Rules of engagement
View 	

    A view is only aware of exactly one view model, and is never aware of any other layer or component. When created, Flutter passes the view model to the view as an argument, exposing the view model's data and command callbacks to the view.

ViewModel 	

    A ViewModel belongs to exactly one view, which can see its data, but the model never needs to know that a view exists.
    A view model is aware of one or more repositories, which are passed into the view model's constructor.

Repository 	

    A repository can be aware of many services, which are passed as arguments into the repository constructor.
    A repository can be used by many view models, but it never needs to be aware of them.

Service 	

    A service can be used by many repositories, but it never needs to be aware of a repository (or any other object).

Dependency injection

This guide has shown how these different components communicate with each other by using inputs and outputs. In every case, communication between two layers is facilitated by passing a component into the constructor methods (of the components that consume its data), such as a Service into a Repository.

class MyRepository {
  MyRepository({required MyService myService})
          : _myService = myService;

  late final MyService _myService;
}

One thing that's missing, however, is object creation. Where, in an application, is the MyService instance created so that it can be passed into MyRepository? This answer to this question involves a pattern known as dependency injection.

In the Compass app, dependency injection is handled using package:provider. Based on their experience building Flutter apps, teams at Google recommend using package:provider to implement dependency injection.

Services and repositories are exposed to the top level of the widget tree of the Flutter application as Provider objects.
dependencies.dart

runApp(
  MultiProvider(
    providers: [
      Provider(create: (context) => AuthApiClient()),
      Provider(create: (context) => ApiClient()),
      Provider(create: (context) => SharedPreferencesService()),
      ChangeNotifierProvider(
        create: (context) => AuthRepositoryRemote(
          authApiClient: context.read(),
          apiClient: context.read(),
          sharedPreferencesService: context.read(),
        ) as AuthRepository,
      ),
      Provider(create: (context) =>
        DestinationRepositoryRemote(
          apiClient: context.read(),
        ) as DestinationRepository,
      ),
      Provider(create: (context) =>
        ContinentRepositoryRemote(
          apiClient: context.read(),
        ) as ContinentRepository,
      ),
      // In the Compass app, additional service and repository providers live here.
    ],
    child: const MainApp(),
  ),
);

Services are exposed only so they can immediately be injected into repositories via the BuildContext.read method from provider, as shown in the preceding snippet. Repositories are then exposed so that they can be injected into view models as needed.

Slightly lower in the widget tree, view models that correspond to a full screen are created in the package:go_router configuration, where provider is again used to inject the necessary repositories.
router.dart

// This code was modified for demo purposes.
GoRouter router(
  AuthRepository authRepository,
) =>
    GoRouter(
      initialLocation: Routes.home,
      debugLogDiagnostics: true,
      redirect: _redirect,
      refreshListenable: authRepository,
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) {
            return LoginScreen(
              viewModel: LoginViewModel(
                authRepository: context.read(),
              ),
            );
          },
        ),
        GoRoute(
          path: Routes.home,
          builder: (context, state) {
            final viewModel = HomeViewModel(
              bookingRepository: context.read(),
            );
            return HomeScreen(viewModel: viewModel);
          },
          routes: [
            // ...
          ],
        ),
      ],
    );

Within the view model or repository, the injected component should be private. For example, the HomeViewModel class looks like this:
home_viewmodel.dart

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required BookingRepository bookingRepository,
    required UserRepository userRepository,
  })  : _bookingRepository = bookingRepository,
        _userRepository = userRepository;

  final BookingRepository _bookingRepository;
  final UserRepository _userRepository;

  // ...
}

Private methods prevent the view, which has access to the view model, from calling methods on the repository directly.

This concludes the code walkthrough of the Compass app. This page only walked through the architecture-related code, but it doesn't tell the whole story. Most utility code, widget code, and UI styling was ignored. Browse the code in the Compass app repository for a complete example of a robust Flutter application built following these principles. 
