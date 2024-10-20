/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

//const {onRequest} = require("firebase-functions/v2/https");
//const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const database = admin.firestore();

// Function to send notification on content creation
exports.sendDailyNotification = functions.pubsub
  .schedule("* * * * *") // Runs every minute, for testing
  .onRun(async (context) => {
    try {
      const currentDate = new Date();
      const hours = currentDate.getHours() + 3;
      const minutes = currentDate.getMinutes();
      const ampm = hours >= 12 ? "PM" : "AM";
      const formattedHours = hours % 12 === 0 ? 12 : hours % 12;
      const formattedMinutes = minutes < 10 ? "0" + minutes : minutes;
      const time = formattedHours + ":" + formattedMinutes + " " + ampm;
      console.log("time ==> " + time);
      console.log(" Starting  notification:");
      // Get current date and time
      // const currentDate = new Date();

      console.log(
        "current date",
        currentDate.getDate() + "/" + (currentDate.getMonth() + 1) + "/" + currentDate.getFullYear()
      );

      // Query Firestore for documents where the stored date and time match the current date and time
      const querySnapshot = await database
        .collection("FcmTokens")
        .where(
          "date",
          "==",
          currentDate.getDate() + "/" + (currentDate.getMonth() + 1) + "/" + currentDate.getFullYear()
        )
        .get();
      console.log("querySnapshot");
      console.log("Query Snapshot:", querySnapshot.docs.length);

      // Loop through the documents
      querySnapshot.forEach((doc) => {
        const docData = doc.data();
        // const docTime = new Date(docData.timestamp).getTime(); // Convert stored time to milliseconds
        console.log("doc time", docData.timestamp);
        console.log("current time", time);

        if (docData.timestamp == time) {
          console.log(" sending daily notification:");
          console.log("Hours:", docData.minutes);

          // Send notification
          sendNotification(docData.fcmT, "electech", "it is been 1 hour open", docData.minutes);
          const totalMinutes = hours * 60 + minutes + docData.minutes; // Convert current time to minutes and add 30 minutes
          const newHours = Math.floor(totalMinutes / 60) % 24; // Convert minutes back to hours, considering the possibility of exceeding 24 hours
          const formattedHours = newHours === 0 ? 12 : newHours > 12 ? newHours - 12 : newHours; // Format hours
          const formattedMinutes = totalMinutes % 60; // Get remaining minutes
          const ampm = newHours >= 12 ? "PM" : "AM"; // Determine AM or PM

          const updatetime = `${formattedHours}:${formattedMinutes < 10 ? "0" : ""}${formattedMinutes} ${ampm}`;

          console.log("time ==> " + updatetime);
          console.log(" Starting  notification:");
          console.log("Time:", updatetime);

          // Update timestamp in Firestore
          doc.ref.update({ timestamp: updatetime });
        }
      });
    } catch (error) {
      console.error("Error sending daily notification:", error);
    }
  });

// Function to send notification
// Function to send notification
function sendNotification(androidNotificationToken, title, body, minutess) {
  const payload = {
    notification: { title, body },
    token: androidNotificationToken,
  };

  admin
    .messaging()
    .send(payload)
    .then((response) => {
      const currentDate = new Date();
      console.log(`Notification Sent at: ${currentDate.toLocaleString()}`);
      console.log("Successful Notification Sent");

      // Format time as hours:minutes am/pm
      const hours = currentDate.getHours() + 3;
      const minutes = currentDate.getMinutes();
      const ampm = hours >= 12 ? "PM" : "AM";
      const formattedHours = hours % 12 === 0 ? 12 : hours % 12;
      const formattedMinutes = minutes < 10 ? "0" + minutes : minutes;
      const notificationTime = formattedHours + ":" + formattedMinutes + " " + ampm;

      // Format date as DD/MM/YYYY
      const day = currentDate.getDate();
      const month = currentDate.getMonth() + 1; // Month is zero-based
      const year = currentDate.getFullYear();
      const notificationDate = day + "/" + month + "/" + year;

      const notificationRef = database.collection("notificationList").doc();
      notificationRef
        .set({
          androidNotificationToken,
          title,
          body,
          duration: minutess,
          time: notificationTime,
          date: notificationDate,
        })
        .then(() => {
          console.log("Notification details saved in Firestore");
        })
        .catch((error) => {
          console.error("Error saving notification details:", error);
        });
    })
    .catch((error) => {
      console.error("Error Sending Notification:", error);
    });
}
