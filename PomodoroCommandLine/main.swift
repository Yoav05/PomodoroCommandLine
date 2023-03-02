import Foundation

func startTimer(interval: TimeInterval, completedIntervals: Int, totalIntervals: Int, restTime: TimeInterval) {
    let pomodoroDuration = interval * 60.0 // interval in seconds
    var remainingTime = pomodoroDuration
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        remainingTime -= 1.0
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        let remainingTimeString = String(format: "%02d:%02d", minutes, seconds)
        print("\rInterval \(completedIntervals + 1) of \(totalIntervals) - Time remaining: \(remainingTimeString)", terminator: "")
        fflush(stdout)
        if remainingTime <= 0 {
            timer.invalidate()
            print("\rInterval \(completedIntervals + 1) of \(totalIntervals) - Pomodoro complete!")
            let pomodoro = Pomodoro(duration: pomodoroDuration)
            
            if completedIntervals + 1 < totalIntervals {
                print("Rest for \(restTime) minutes. Press enter to start rest.")
                startRestingTimer(interval: restTime) {
                    startTimer(
                        interval: interval,
                        completedIntervals: completedIntervals + 1,
                        totalIntervals: totalIntervals,
                        restTime: restTime
                    )
                }
            } else {
                print("\nAll intervals complete!")
                exit(0)
            }
        }
    }
    print("Pomodoro timer started for \(interval) minutes with a total of \(totalIntervals) intervals and \(restTime) minutes of rest time!")
    RunLoop.current.add(timer, forMode: .common)
}

func startRestingTimer(interval: TimeInterval, completion: @escaping () -> Void) {
    let _ = readLine()
    let restingTime = interval * 60.0
    var remainingTime = restingTime
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        remainingTime -= 1.0
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        let remainingTimeString = String(format: "%02d:%02d", minutes, seconds)
        print("\rResting - Time remaining: \(remainingTimeString)", terminator: "")
        if remainingTime <= 0 {
            timer.invalidate()
            print("Rest for \(interval) minutes. Press enter to start next interval.")
            let _ = readLine()
            completion()
        }
    }
    RunLoop.current.add(timer, forMode: .common)
}


func recordPomodoro(_ pomodoro: Pomodoro) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = dateFormatter.string(from: pomodoro.endTime)
    let pomodoroRecord = "\(timestamp) - Pomodoro completed\n"
    let filename = "pomodoros.txt"
    if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename) {
        do {
            try pomodoroRecord.appendLineToURL(fileURL: fileURL)
        } catch {
            print("Error writing to file: \(error)")
        }
    } else {
        print("Error creating file URL")
    }
}


struct Pomodoro {
    let duration: TimeInterval
    let endTime: Date

    init(duration: TimeInterval) {
        self.duration = duration
        self.endTime = Date().addingTimeInterval(duration)
    }
}

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }

    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8)!
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: fileURL, options: .atomic)
        }
    }
}

print("Enter the interval time in minutes:")
if let intervalString = readLine(), let interval = Double(intervalString) {
    print("Enter the total number of intervals:")
    if let totalIntervalsString = readLine(), let totalIntervals = Int(totalIntervalsString) {
        print("Enter the rest time in minutes:")
        if let restTimeString = readLine(), let restTime = Double(restTimeString) {
            startTimer(interval: interval, completedIntervals: 0, totalIntervals: totalIntervals, restTime: restTime)
            RunLoop.current.run()
        } else {
            print("Invalid rest time")
        }
    } else {
        print("Invalid total number of intervals")
    }
} else {
    print("Invalid interval time")
}
