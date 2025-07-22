import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet : Bool
    
    var body: some View {
        Button {
            isSet.toggle()
        } label : {
            Label("Favorite", systemImage: isSet ? "star.fill" : "star")
                .labelStyle(IconOnlyLabelStyle())
                .foregroundStyle(isSet ? .yellow : .gray)
        }
    }
}

#Preview {
    FavoriteButton(isSet: .constant(true))
}
