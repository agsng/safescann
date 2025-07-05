// public/js/api/firestore-api.js
import { db } from '../config/firebase-config.js'; // Import the db instance
import { doc, getDoc } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";
import { messageDiv } from '../utils/dom-utils.js'; // Import messageDiv for error display

/**
 * Fetches public vehicle details from Firestore.
 * @param {string} qrCodeUuid The UUID of the QR code.
 * @returns {Promise<Object|null>} The public vehicle data or null if not found/error.
 */
async function fetchPublicVehicleDetails(qrCodeUuid) {
    messageDiv.textContent = 'Fetching vehicle details...';
    try {
        const docRef = doc(db, 'PublicVehicleDetails', qrCodeUuid);
        const docSnap = await getDoc(docRef);

        if (docSnap.exists()) {
            return docSnap.data();
        } else {
            messageDiv.textContent = 'No vehicle details found for this QR code.';
            messageDiv.classList.add('text-red-600');
            return null;
        }
    } catch (error) {
        console.error("Error fetching document:", error);
        messageDiv.textContent = `Error loading details: ${error.message}. Please try again.`;
        messageDiv.classList.add('text-red-600');
        return null;
    }
}

export { fetchPublicVehicleDetails };
