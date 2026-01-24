//
//  DeleteAccountView.swift
//  PluhykBloomora
//
//  Created on 2026-01-24.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(DataPersistenceService.Keys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    
    @State private var confirmationText = ""
    @State private var showingFinalConfirmation = false
    @State private var dataDeleted = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Warning Icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 70))
                .foregroundColor(.red)
            
            // Title
            Text("Delete All Data")
                .font(.system(size: 28, weight: .bold))
            
            // Warning Message
            VStack(spacing: 15) {
                Text("This action cannot be undone!")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.red)
                
                Text("All your tasks, journal entries, mindfulness records, and settings will be permanently deleted.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Confirmation Input
            VStack(alignment: .leading, spacing: 10) {
                Text("Type DELETE to confirm:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                
                TextField("DELETE", text: $confirmationText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.allCharacters)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 15) {
                Button(action: {
                    if confirmationText == "DELETE" {
                        showingFinalConfirmation = true
                    }
                }) {
                    Text("Delete All Data")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(confirmationText == "DELETE" ? Color.red : Color.gray)
                        .cornerRadius(15)
                }
                .disabled(confirmationText != "DELETE")
                .padding(.horizontal, 40)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "#2490ad"))
                }
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Delete Data")
        .alert("Final Confirmation", isPresented: $showingFinalConfirmation) {
            Button("Yes, Delete Everything", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you absolutely sure? This will delete ALL your data permanently.")
        }
        .alert("Data Deleted", isPresented: $dataDeleted) {
            Button("OK") {
                hasCompletedOnboarding = false
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("All your data has been deleted. The app will restart.")
        }
    }
    
    private func deleteAllData() {
        DataPersistenceService.shared.clearAllData()
        dataDeleted = true
    }
}

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
    }
}
