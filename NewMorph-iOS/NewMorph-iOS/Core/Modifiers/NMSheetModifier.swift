import SwiftUI

struct NMSheetModifier<SheetContent: View>: ViewModifier {
    @State private var offsetY: CGFloat = 0
    
    @Binding var isPresented: Bool
    private let sheetContent: SheetContent
    private let onDismiss: (() -> Void)?
    
    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> SheetContent
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.sheetContent = content()
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPresented = false }
                        onDismiss?()
                    }
                    .accessibilityHidden(true)
                
                VStack {
                    Spacer()
                    NMSheet {
                        sheetContent
                    }
                    .offset(y: offsetY)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    offsetY = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > 100 {
                                    isPresented = false
                                    onDismiss?()
                                }
                                offsetY = 0
                            }
                    )
                }
                .ignoresSafeArea()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: isPresented)
            }
        }
        .onChange(of: isPresented) { _, isPresented in
            if !isPresented { onDismiss?() }
        }
    }
}

extension View {
    func nmSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(
            NMSheetModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}
