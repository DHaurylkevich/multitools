import SwiftUI

struct WindowLabel: View {
    let title: String
    let icon: String
    
    var body: some View{
        HStack {
            Label(title, systemImage: icon)
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
        }
    }
}
