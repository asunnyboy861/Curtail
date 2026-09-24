import SwiftUI

struct ContactSupportView: View {
    @State private var subject = "General"
    @State private var customSubject = ""
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var submissionResult: SubmissionResult?
    @State private var showOtherInput = false

    private let backendBaseURL = "https://feedback-board.iocompile67692.workers.dev"
    private let appName = "Curtail"
    private let maxMessageLength = 1000

    private let subjects: [(title: String, icon: String)] = [
        ("General", "bubble.left.fill"),
        ("Feature Suggestion", "lightbulb.fill"),
        ("Bug Report", "ant.fill"),
        ("Usage Question", "questionmark.circle.fill"),
        ("Performance Issue", "gauge.with.dots.needle.67percent"),
        ("UI Improvement", "paintpalette.fill"),
        ("Other", "ellipsis.circle.fill")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                subjectGrid

                if showOtherInput {
                    TextField("Custom subject…", text: $customSubject)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Name").font(.caption).foregroundStyle(CurtailTheme.textMid)
                    TextField("Your name", text: $name)
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Email").font(.caption).foregroundStyle(CurtailTheme.textMid)
                    TextField("yourname@example.com", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Message").font(.caption).foregroundStyle(CurtailTheme.textMid)
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(CurtailTheme.textHi)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
                    HStack {
                        Spacer()
                        Text("\(message.count) / \(maxMessageLength)")
                            .font(.caption2)
                            .foregroundStyle(CurtailTheme.textMid)
                    }
                }

                Button {
                    submit()
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Submit")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(CurtailTheme.wave)
                .disabled(!isFormValid || isSubmitting)

                Text("We only use your email to respond to this feedback.")
                    .font(.caption2)
                    .foregroundStyle(CurtailTheme.textMid)
                    .frame(maxWidth: .infinity)

                resultBanner
            }
            .padding(20)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Contact Support")
    }

    private var subjectGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(subjects.prefix(6), id: \.title) { item in
                subjectTile(item.title, icon: item.icon)
            }
            subjectTile("Other", icon: "ellipsis.circle.fill", fullWidth: true)
        }
    }

    private func subjectTile(_ title: String, icon: String, fullWidth: Bool = false) -> some View {
        let selected = subject == title
        return Button {
            subject = title
            showOtherInput = title == "Other"
        } label: {
            VStack(spacing: 8) {
                Image(systemName: selected ? "checkmark.circle.fill" : icon)
                    .font(.title3)
                    .foregroundStyle(selected ? .white : CurtailTheme.wave)
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(selected ? .white : CurtailTheme.textHi)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(selected ? CurtailTheme.wave : CurtailTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(selected ? .clear : CurtailTheme.textMid.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(selected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title)\(selected ? ", selected" : "")")
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && isValidEmail(email)
            && effectiveSubject != ""
            && !message.trimmingCharacters(in: .whitespaces).isEmpty
            && message.count <= maxMessageLength
    }

    private var effectiveSubject: String {
        subject == "Other" ? customSubject.trimmingCharacters(in: .whitespaces) : subject
    }

    private var resultBanner: some View {
        Group {
            if let result = submissionResult {
                HStack(spacing: 10) {
                    Image(systemName: result.isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                        .foregroundStyle(result.isSuccess ? CurtailTheme.mint : CurtailTheme.coral)
                    Text(result.text)
                        .font(.subheadline)
                        .foregroundStyle(CurtailTheme.textHi)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
            }
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        value.contains("@") && value.contains(".") && !value.hasPrefix("@") && !value.hasSuffix(".")
    }

    private func submit() {
        isSubmitting = true
        submissionResult = nil
        let payload = FeedbackRequest(
            name: name.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            subject: effectiveSubject,
            message: message,
            app_name: appName
        )
        guard let url = URL(string: "\(backendBaseURL)/api/feedback"),
              let body = try? JSONEncoder().encode(payload) else {
            isSubmitting = false
            submissionResult = .init(isSuccess: false, text: "Something went wrong. Please try again.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                    await MainActor.run {
                        isSubmitting = false
                        submissionResult = .init(isSuccess: true, text: "Thank you! Your feedback has been sent.")
                        message = ""
                    }
                } else {
                    let text = (try? JSONDecoder().decode([String: String].self, from: data)["error"]) ?? "Something went wrong. Please try again."
                    await MainActor.run {
                        isSubmitting = false
                        submissionResult = .init(isSuccess: false, text: text)
                    }
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    submissionResult = .init(isSuccess: false, text: "Something went wrong. Please try again.")
                }
            }
        }
    }
}

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}

struct SubmissionResult {
    let isSuccess: Bool
    let text: String
}
