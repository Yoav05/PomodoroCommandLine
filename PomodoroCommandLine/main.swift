import Foundation

func startTimer(interval: TimeInterval, completedIntervals: Int, totalIntervals: Int, restTime: TimeInterval) {
    print()
    let pomodoroDuration = interval * 60.0 // interval in seconds
    var remainingTime = pomodoroDuration
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        remainingTime -= 1.0
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        let remainingTimeString = String(format: "%02d:%02d", minutes, seconds)
        print("\rTime remaining: \(remainingTimeString)", terminator: "")
        fflush(stdout)
        if remainingTime <= 0 {
            timer.invalidate()
            print("\rInterval \(completedIntervals + 1)/\(totalIntervals) - complete!\n")
            if completedIntervals + 1 < totalIntervals {
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
    print("Interval \(completedIntervals + 1)/\(totalIntervals)")
    RunLoop.current.add(timer, forMode: .common)
}

func startRestingTimer(interval: TimeInterval, completion: @escaping () -> Void) {
    print("\rPress enter to start rest.", terminator: "")
    let _ = readLine()
    let restingTime = interval * 60.0
    var remainingTime = restingTime
    let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
        remainingTime -= 1.0
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        let remainingTimeString = String(format: "%02d:%02d", minutes, seconds)
        print("\rTime remaining: \(remainingTimeString)", terminator: "")
        fflush(stdout)
        if remainingTime <= 0 {
            timer.invalidate()
            print("\rPress enter to end rest.", terminator: "")
            let _ = readLine()
            completion()
        }
    }
    RunLoop.current.add(timer, forMode: .common)
}

func parseArguments() -> (interval: Double, totalIntervals: Int, restTime: Double)? {
    // Set default values
    var interval = 0.1
    var totalIntervals = 2
    var restTime = 0.1
    
    // Get the command line arguments
    let args = CommandLine.arguments
    
    // Parse the arguments
    var i = 1
    while i < args.count {
        switch args[i] {
        case "--interval", "-i":
            if let value = Double(args[i+1]) {
                interval = value
            }
            i += 2
        case "--total-intervals", "-t":
            if let value = Int(args[i+1]) {
                totalIntervals = value
            }
            i += 2
        case "--rest-time", "-r":
            if let value = Double(args[i+1]) {
                restTime = value
            }
            i += 2
        default:
            print("Unknown argument: \(args[i])")
            return nil
        }
    }
    
    // Return the parsed arguments
    return (interval, totalIntervals, restTime)
}

func main() {
    guard let (interval, totalIntervals, restTime) = parseArguments() else { return }
    startTimer(interval: interval, completedIntervals: 0, totalIntervals: totalIntervals, restTime: restTime)
    RunLoop.current.run()
}

main()
