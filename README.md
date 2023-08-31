# MV Architecture for SwiftUI
### Articles related to this project

* [Building Large-Scale Apps with SwiftUI: A Guide to Modular Architecture](https://azamsharp.com/2023/02/28/building-large-scale-apps-swiftui.html)
* [Clean Architecture for SwiftUI](https://nalexn.github.io/clean-architecture-swiftui/?utm_source=nalexn_github)

---
A demo project showcasing the setup of the SwiftUI app with MV Architecture.

The app uses the [restcountries.com](https://restcountries.com/) REST API to show the list of countries and details about them.

![platforms](https://img.shields.io/badge/platforms-iPhone%20%7C%20iPad%20%7C%20macOS-lightgrey) 

## Key features
* Vanilla **SwiftUI** implementation
* Decoupled **Presentation**, **Business Logic**, and **Data Access** layers
* 85% test coverage, including the UI
* **Redux**-like centralized state as the single source of truth
* Native SwiftUI dependency injection
* **Programmatic navigation**.
* Simple yet flexible networking layer built on Generics
* Built with SOLID and DRY
* Designed for scalability. It can be used as a reference for building large production apps

### Presentation Layer
**SwiftUI views** that contain no business logic and are a function of the state.

### Business Logic Layer
Business Logic Layer is represented by `ObservableObject Model`. 

### Data Access Layer
Data Access Layer is represented by `HTTPClient` (TODO: add repository).

