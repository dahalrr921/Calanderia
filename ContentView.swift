import SwiftUI
struct User: Codable {
    var username: String
    var password: String
}
func saveUsersToUserDefaults(_ users: [User]) {
    if let encoded = try? JSONEncoder().encode(users) {
        UserDefaults.standard.set(encoded, forKey: "usersDatabase")
    }
}

func loadUsersFromUserDefaults() -> [User] {
    if let data = UserDefaults.standard.data(forKey: "usersDatabase"),
       let decoded = try? JSONDecoder().decode([User].self, from: data) {
        return decoded
    }
    return []
}

struct TimeSlot: Codable, Hashable {
    var start: String
    var end: String
}

struct DailySchedule: Codable {
    var classTime: TimeSlot
    var workTime: TimeSlot
}




func generateWeeklySchedule(studyHours: Int, freeDays: [String], workDays: [String]) -> [String: Int] {
    let availableDays = freeDays.filter { !workDays.contains($0) }
    guard !availableDays.isEmpty, studyHours > 0 else { return [:] }
    
    let hoursPerDay = studyHours / availableDays.count
    var schedule: [String: Int] = [:]
    
    for day in availableDays {
        schedule[day] = hoursPerDay
    }
    
    let remainder = studyHours % availableDays.count
    for i in 0..<remainder {
        let day = availableDays[i]
        schedule[day, default: 0] += 1
    }

    return schedule
}




struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false
    @State private var navigateToSignUp = false
    @State private var usersDatabase: [User] = loadUsersFromUserDefaults()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Image
                Image("Calander")
                    .resizable()
                    .blur(radius: 5)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()

                    // Form Background
                    VStack(spacing: 20) {
                        Text("Welcome to Calanderia!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.0))

                        TextField("Enter your username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                        TextField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)

                        Button(action: {
                            if let _ = usersDatabase.first(where: { $0.username == username && $0.password == password }) {
                                isLoggedIn = true
                            } else {
                                print("Invalid username or password.")
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

                        NavigationLink(destination: SignUpView(usersDatabase: $usersDatabase), isActive: $navigateToSignUp) {
                            Button(action: {
                                navigateToSignUp = true
                            }) {
                                Text("First time? Sign up")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green)
                                    .cornerRadius(10)
                            }
                        }
                        
                    }
                    .padding()
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 40)

                    Spacer()
                }
                
                NavigationLink(destination: DashboardView(), isActive: $isLoggedIn) {
                    EmptyView()
                }

            }
        }
    }
}







struct SignUpView: View {
    @Binding var usersDatabase: [User]
    @Environment(\.presentationMode) var presentationMode

    @State private var newUsername = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            
            Image("Calander")
                .resizable()
                .scaledToFill()
                .blur(radius: 0)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    Rectangle()
                        .stroke(Color.brown, lineWidth: 5)
                )
            
            Text("Create Account")
                .font(.largeTitle)
                .bold()

            TextField("Username", text: $newUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
            TextField("Password", text: $newPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button("Sign Up") {
                if newUsername.isEmpty || newPassword.isEmpty {
                    errorMessage = "All fields are required."
                } else if newPassword != confirmPassword {
                    errorMessage = "Passwords do not match."
                } else if usersDatabase.contains(where: { $0.username == newUsername }) {
                    errorMessage = "Username already exists."
                } else {
                    usersDatabase.append(User(username: newUsername, password: newPassword))
                    saveUsersToUserDefaults(usersDatabase)  
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}








// Dashboard Screen
struct DashboardView: View {
    @State private var isInGroup = false
    // Tracks if user is in a group

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ScheduleView()
                            .tabItem {
                                Label("Schedule", systemImage: "calendar")
                            }
            
            
                    }
    }
}


struct HomeView: View {
    
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
    @AppStorage("hasEnteredSchedule") private var hasEnteredSchedule = false
    @AppStorage("weeklySchedule") private var weeklyScheduleData: Data = Data()

    @State private var schedule: [String: DailySchedule] = [:]

    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    
    @State private var classStart: [String: Date] = [:]
    @State private var classEnd: [String: Date] = [:]
    @State private var workStart: [String: Date] = [:]
    @State private var workEnd: [String: Date] = [:]
    @State private var tempSleepStart = Date()
    @State private var tempSleepEnd = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("😴 Sleep Time")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("10:00 PM - 06:00 AM (Everyday)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(0.1)
                                        .padding(10)
                                )
                        )
                    }

                    ForEach(daysOfWeek, id: \.self) { day in
                        Section(header:
                            Text(day)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.0))
                        ) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Class Time")
                                    .fontWeight(.semibold)

                                HStack {
                                    DatePicker("Start", selection: Binding(
                                        get: { classStart[day, default: Date()] },
                                        set: { classStart[day] = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)

                                    Text("-")

                                    DatePicker("End", selection: Binding(
                                        get: { classEnd[day, default: Date()] },
                                        set: { classEnd[day] = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                }

                                if let start = workStart[day], let end = workEnd[day] {
                                    Text("Selected: \(formatTime(start)) - \(formatTime(end))")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                Text("Work Time")
                                    .fontWeight(.semibold)

                                HStack {
                                    DatePicker("Start", selection: Binding(
                                        get: { workStart[day, default: Date()] },
                                        set: { workStart[day] = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)

                                    Text("-")

                                    DatePicker("End", selection: Binding(
                                        get: { workEnd[day, default: Date()] },
                                        set: { workEnd[day] = $0 }
                                    ), displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity)
                                }

                                if let start = classStart[day], let end = classEnd[day] {
                                    Text("Selected: \(formatTime(start)) - \(formatTime(end))")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                Button(hasEnteredSchedule ? "Save Changes" : "Generate Schedule") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "hh:mm a"

                    for day in daysOfWeek {
                        let cStart = formatter.string(from: classStart[day] ?? Date())
                        let cEnd = formatter.string(from: classEnd[day] ?? Date())
                        let wStart = formatter.string(from: workStart[day] ?? Date())
                        let wEnd = formatter.string(from: workEnd[day] ?? Date())

                        schedule[day] = DailySchedule(
                            classTime: TimeSlot(start: cStart, end: cEnd),
                            workTime: TimeSlot(start: wStart, end: wEnd)
                        )
                    }

                    if let encoded = try? JSONEncoder().encode(schedule) {
                        weeklyScheduleData = encoded
                        hasEnteredSchedule = true
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Clear Schedule") {
                    hasEnteredSchedule = false
                    weeklyScheduleData = Data()
                    schedule = [:]
                    classStart = [:]
                    classEnd = [:]
                    workStart = [:]
                    workEnd = [:]
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .navigationTitle("Home")
        }
    }
}



import SwiftUI

struct ScheduleView: View {
    @AppStorage("weeklySchedule") private var weeklyScheduleData: Data = Data()
    @State private var freeTimeSchedule: [String: [TimeSlot]] = [:]

    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        NavigationView {
            List {
                if freeTimeSchedule.isEmpty {
                    Text("No schedule found. Please create one from Home.")
                        .foregroundColor(.gray)
                } else {
                    ForEach(daysOfWeek, id: \.self) { day in
                        if let slots = freeTimeSchedule[day], !slots.isEmpty {
                            Section(header: Text(day)) {
                                ForEach(slots, id: \.self) { slot in
                                    Text("\(slot.start) - \(slot.end)")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .onAppear(perform: loadAndCalculateFreeTime)
        }
    }

    func loadAndCalculateFreeTime() {
        guard let decoded = try? JSONDecoder().decode([String: DailySchedule].self, from: weeklyScheduleData) else {
            print("❌ Failed to decode schedule")
            freeTimeSchedule = [:]
            return
        }

        print("✅ Decoded schedule:", decoded)

        var result: [String: [TimeSlot]] = [:]
        for (day, entry) in decoded {
            let classStart = parseTime(entry.classTime.start)
            let classEnd = parseTime(entry.classTime.end)
            let workStart = parseTime(entry.workTime.start)
            let workEnd = parseTime(entry.workTime.end)

            let busySlots = [
                TimeSlot(start: entry.classTime.start, end: entry.classTime.end),
                TimeSlot(start: entry.workTime.start, end: entry.workTime.end)
            ].filter { !$0.start.isEmpty && !$0.end.isEmpty }

            var allSlots = [
                TimeSlot(start: "06:00 AM", end: "10:00 PM")
            ]

            for busy in busySlots {
                allSlots = subtractSlot(from: allSlots, removing: busy)
            }

            // Add default quiet time if needed (optional)
            result[day] = allSlots
        }

        print("✅ Calculated free time:", result)
        freeTimeSchedule = result
    }

    func subtractSlot(from slots: [TimeSlot], removing: TimeSlot) -> [TimeSlot] {
        var result: [TimeSlot] = []
        for slot in slots {
            let startA = parseTime(slot.start)
            let endA = parseTime(slot.end)
            let startB = parseTime(removing.start)
            let endB = parseTime(removing.end)

            if endA <= startB || startA >= endB {
                result.append(slot) // no overlap
            } else {
                if startA < startB {
                    result.append(TimeSlot(start: formatTime(startA), end: formatTime(startB)))
                }
                if endB < endA {
                    result.append(TimeSlot(start: formatTime(endB), end: formatTime(endA)))
                }
            }
        }
        return result
    }

    func parseTime(_ str: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        if let date = formatter.date(from: str) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            let minute = calendar.component(.minute, from: date)
            return hour * 60 + minute
        }
        return 0
    }

    func formatTime(_ minutes: Int) -> String {
        let hour = minutes / 60
        let minute = minutes % 60
        let ampm = hour >= 12 ? "PM" : "AM"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return String(format: "%02d:%02d %@", hour12, minute, ampm)
    }
}





// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

