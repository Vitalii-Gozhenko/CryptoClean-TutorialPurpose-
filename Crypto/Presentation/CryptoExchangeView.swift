//
//  CryptoExchangeView.swift
//  Crypto
//
//  Created by Daniil Gozhenko on 16.06.2022.
//

import SwiftUI

struct CryptoExchangeView: View {
  // Question: Why you initializing your view model directly?
    @StateObject private var viewModel = ViewModel()
    var body: some View {
        LoadingView(isShowing: $viewModel.loading) {
            VStack {
                VStack {
                  // Question: Why amount is in $?

                  // Question: What is wrong here with the stepper value range validation?
                    Stepper("Amount: \(Int(viewModel.amount))$", value: $viewModel.amount, step: 100)
                    Slider(value: $viewModel.amount, in: 1...10000)
                }
                .padding()
                
                List(viewModel.filteredRates) { rateItem in
                    HStack {
                        Text(rateItem.shortCurrencyCode)
                            .bold()
                        Spacer()
                      // Question: Why you are thinking that you are displaying rate in $?
                      // Question: Why your view has knowledge about exact currency?
                      // Question: What business logic error you have here?
                        Text("$\(viewModel.calculateRate(rate: rateItem), specifier: "%.2f")")
                    }
                }
                .listStyle(.plain)
                .searchable(text: $viewModel.searchText)
            }
            .task {
                await viewModel.refreshData()
            }
            .alert("Error", isPresented: $viewModel.hasError) {
            } message: {
                Text(viewModel.errorMessage)
            }
            .navigationTitle("CRYPTO")
            .toolbar {
                ToolbarItem {
                    Button("Refresh", action: {
                        Task {
                           await viewModel.refreshData()
                        }
                    })
                }
            }
        }
        
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }

}

struct CryptoExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoExchangeView()
    }
}
