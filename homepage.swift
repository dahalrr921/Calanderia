import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("Calander")
                    .resizable()
                    .blur(radius: 5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer() // Pushes the form down

                    
                    // Form Background
                    VStack(spacing: 15) {
                        
                        Text("Welcome to Calanderia")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.0))
                        
                        TextField("Enter your username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                        // Login Button
                        Button(action: {
                            if !username.isEmpty && !password.isEmpty {
                                isLoggedIn = true
                            }
                        }) {
                            Text("Login")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        
                        // Navigation to Dashboard
                        NavigationLink(destination: DashboardView(), isActive: $isLoggedIn) {
                            EmptyView()
                        }
                        
                        // Sign Up Button
                        Button(action: {
                            // Sign-up action
                        }) {
                            Text("Sign up")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 40)

                    Spacer() // Pushes the form up
                }
            }
        }
    }
}

