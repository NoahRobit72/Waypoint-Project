import SwiftUI

struct ContentView: View {
    @GestureState private var tapLocation: CGPoint = .zero
    
    
    // This will hold
    @State private var points: [CGPoint] = []
    
    private let deleteParameter: CGFloat = 20

    
    var body: some View {
        ZStack {
            
            Text("Little's Lab")
                .position(x: UIScreen.main.bounds.width / 2, y: 200)
                .font(.title)
            drawCircles(at: points).zIndex(1) // Ensure circles are above other views
            lineView(at: points).zIndex(2)
            

            Rectangle()
                .fill(Color.gray)
                .frame(width: 200, height: 200)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($tapLocation) { value, state, _ in
                            state = value.location
                        }
                        .onEnded { value in
                            // Establish constants
                            var closestPointIndex = 0
                            var deleting = 0
                            var minDistance = CGFloat.greatestFiniteMagnitude
                           
                            // Get the location of the tap in points
                            let xValOG = value.location.x
                            let yValOG = value.location.y
                            
                            // Recenter the points to be in centered at (0,0)
                            var xVal = xValOG - (UIScreen.main.bounds.width / 2)
                            var yVal = yValOG - (UIScreen.main.bounds.height / 2)
                            
                            // Convert to points from 100 x 100 to 1200 x 1000
                            xVal = (11 * xVal) + 100
                            yVal = (12 * yVal)
                            
                            // Print and establish a point
//                            print("User clicked point: (\(xVal), \(yVal))")
                            let point = CGPoint(x: xValOG, y: yValOG)

                           // For the array, find the min distance point,
                            for (index, p) in points.enumerated() {
                                let distance = distanceBetween(p, point)
                                if distance < minDistance {
                                    minDistance = distance
                                    closestPointIndex = index
                                }
                            }
                            
                            // If you tapped close to another point, you are deleting
                            if (minDistance < deleteParameter) {deleting = 1}
                            
                            
                            
                            
                            // If deleting
                            if(deleting == 1){
                                print("you are deleting")
                                print("There are \(points.count) points before deleting")

                                                                
                                // If there is one point (start and finish)
                                if(points.count == 2){
                                    points.remove(at: 0)
                                    points.remove(at: 0)
                                }
                                
                                // If there is more than one point
                                else{
                                    if(closestPointIndex == 0){
                                        print("This is a start point")
                                        // Remove point
                                        points.remove(at: closestPointIndex)
                                        points.remove(at: (points.count-1))
                                        
                                        // Reset starting point
                                        points.append(points[0])
                                    }
                                    else{
                                        print("This is not a start point")
                                        points.remove(at: closestPointIndex)
                                    }
                                }
                                
                                print("There are \(points.count) points after deleting")

                                
                            }
                            // If adding
                            else{
                                print("you are not deleting")
                                print("There are \(points.count) points before adding")


                                // Adding N points
                                if(points.count > 0){points.insert(point, at: (points.count - 1))}
                      
                                // If the if the array is empty, add point as start and finish
                                if(points.count == 0){
                                    points.append(point)
                                    points.append(point)
                                }
                                
                                print("There are \(points.count) points after adding")

                            }
                            
                        }
                )
            Button(action: {
                handleTap(at: points)
                // Action to perform when button is tapped
                print("Button tapped!")
            }) {
                Text("Submit Points")
                    .frame(width: 200, height: 70) // Adjust the width and height as needed
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

            }
            .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 200)
                
        }
    }
    
    @ViewBuilder
    func lineView(at points: [CGPoint]) -> some View {
        GeometryReader { geometry in
            Path { path in
                // Start drawing from the first point
                path.move(to: self.points.first ?? .zero)

                // Add lines to the rest of the points
                for point in self.points.dropFirst() {
                    path.addLine(to: point)
                }
            }
            .stroke(Color.blue, lineWidth: 2) // Customize line color and width here
        }
    }
    
    
    @ViewBuilder
    func drawCircles(at points: [CGPoint]) -> some View {
        ForEach(0..<points.count, id: \.self) { index in
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .position(x: points[index].x, y: points[index].y)
        }
    }
    // Function to handle the tap
      func handleTap(at points: [CGPoint]) {
          // Your custom logic here
          // Example async function call
          Task {
              await sendRequest(at: points)
          }
      }

      // Asynchronous function to send a request
      func sendRequest(at points: [CGPoint]) async {
          // Convert points array to JSON format
          let pointDictionaries = points.map { ["xVal": $0.x, "yVal": $0.y] }
          guard let postData = try? JSONSerialization.data(withJSONObject: pointDictionaries, options: []) else {
              print("Error encoding parameters")
              return
          }

          guard let url = URL(string: "http://127.0.0.1:8080/test") else {
              print("Invalid URL")
              return
          }
          var request = URLRequest(url: url, timeoutInterval: Double.infinity)
          request.addValue("application/json", forHTTPHeaderField: "Content-Type")
          request.httpMethod = "POST"
          request.httpBody = postData
          do {
              let (data, _) = try await URLSession.shared.data(for: request)
              if let responseString = String(data: data, encoding: .utf8) {
                  print("Response: \(responseString)")
              } else {
                  print("Unable to convert data to string")
              }
          } catch {
              print("Error: \(error.localizedDescription)")
          }
      }
    
        func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
            let dx = point2.x - point1.x
            let dy = point2.y - point1.y
            return sqrt(dx * dx + dy * dy)
        }
  }

#Preview {
    ContentView()
}
