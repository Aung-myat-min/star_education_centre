# star_education_centre

> This is a Student and Course Management Application. Developed for my year 2 university assignment.

In this application, I use:
- **Flutter** for frontend
- **Firebase** for backend

## SOLID Principles
I applied SOLID principles in this project.

I used Single Responsibility in every project.
> - Every object only responsible for its creation and transformation. (SRP) (Singleton Pattern)
> - Methods of every object are separated by the principle of SRP.
> - Person Abstract Object can be extended without needing to altering the base code. (LSP)
> - In Student, _id(s) are private, allowing the program only to access it but cannot update it. (OCP)
> - There is a student factory method which returns the associated Student Class according to the number of course he/she applied. (Factory Pattern)