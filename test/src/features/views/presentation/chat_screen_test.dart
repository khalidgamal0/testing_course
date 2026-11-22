// # Chat Screen Test Cases
//
// ### Case 1: Loading Indicator on Send
// - **Action:** User sends a message.
// - **Expectation:** The loading indicator appears in the message list.
//
// ---
//
// ### Case 2: Successful AI Response
// - **Action:** User sends a message and the API responds successfully.
// - **Expectation:** The AI response bubble appears with the correct text.
//
// ---
//
// ### Case 3: API Failure & Successful Retry
// - **Action:** User sends a message and the API fails.
// - **Expectation:** The failure bubble appears.
// - **Action:** User taps retry.
// - **Expectation:** The AI response bubble appears with the correct text.
//
// ---
//
// ### Case 4: API Failure & Repeated Retry Failure
// - **Action:** User sends a message and the API fails.
// - **Expectation:** The failure bubble appears.
// - **Action:** User taps retry and the API fails again.
// - **Expectation:** The failure bubble remains visible.
//
// ---
//
// ### Case 5: API Failure & Sending New Message
// - **Action:** User sends a message and the API fails.
// - **Expectation:** The failure bubble appears.
// - **Action:** User sends a new message.
// - **Expectation:** The previous failure bubble is removed.