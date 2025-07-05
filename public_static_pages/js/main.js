// public/js/main.js
import { fetchPublicVehicleDetails } from './api/firestore-api.js';
import { setContactInfo } from './services/contact-actions.js';
import {
    messageDiv,
    qrSection,
    qrCodeUuidSpan,
    vehicleInfoSection,
    vehicleDetailsList,
    ownerInfoSection,
    ownerDetailsList,
    emergencyContactsSection,
    emergencyContactsList,
    getQrCodeUuidFromUrl,
    populateDetailsList
} from './utils/dom-utils.js';

/**
 * Displays the fetched vehicle details on the page.
 * @param {Object} data The public vehicle data.
 */
function displayVehicleDetails(data) {
    messageDiv.classList.add('hidden'); // Hide loading message

    // QR Code Section
    qrCodeUuidSpan.textContent = data.qrCodeUuid || 'N/A';
    qrSection.classList.remove('hidden');

    // Vehicle Information
    if (data.vehiclePublicInfo) {
        populateDetailsList(vehicleDetailsList, data.vehiclePublicInfo, ['qrCodeUuid', 'ownerUserId']);
        vehicleInfoSection.classList.remove('hidden');
    }

    // Owner Information
    if (data.ownerPublicInfo) {
        // Exclude emergencyContacts array from direct display in owner info
        populateDetailsList(ownerDetailsList, data.ownerPublicInfo, ['emergencyContacts']);
        ownerInfoSection.classList.remove('hidden');

        // Set contact info for action buttons
        setContactInfo(data.ownerPublicInfo.primaryPhoneNumber, data.ownerPublicInfo.emergencyContacts);
    }

    // Emergency Contacts
    const emergencyContacts = data.ownerPublicInfo?.emergencyContacts || [];
    if (emergencyContacts.length > 0) {
        emergencyContactsList.innerHTML = ''; // Clear previous content
        emergencyContacts.forEach((contact, index) => {
            const contactDiv = document.createElement('div');
            contactDiv.className = 'border border-gray-200 rounded-md p-3 mb-2 bg-gray-50';
            contactDiv.innerHTML = `
                <p><span class="font-semibold">Contact ${index + 1}:</span></p>
                <div class="detail-item"><span class="detail-label">Name:</span> <span class="detail-value">${contact.name || 'N/A'}</span></div>
                <div class="detail-item"><span class="detail-label">Relationship:</span> <span class="detail-value">${contact.relationship || 'N/A'}</span></div>
                <div class="detail-item"><span class="detail-label">Phone:</span> <span class="detail-value">${contact.phone || 'N/A'}</span></div>
                <div class="detail-item"><span class="detail-label">Email:</span> <span class="detail-value">${contact.email || 'N/A'}</span></div>
            `;
            emergencyContactsList.appendChild(contactDiv);
        });
        emergencyContactsSection.classList.remove('hidden');
    } else {
        emergencyContactsList.innerHTML = '<p class="text-gray-500">No emergency contacts listed.</p>';
        emergencyContactsSection.classList.remove('hidden'); // Still show section, but with message
    }
}

// Initial fetch when the page loads
document.addEventListener('DOMContentLoaded', async () => {
    const qrCodeUuid = getQrCodeUuidFromUrl();
    if (qrCodeUuid) {
        const data = await fetchPublicVehicleDetails(qrCodeUuid);
        if (data) {
            displayVehicleDetails(data);
        }
    } else {
        messageDiv.textContent = 'QR Code ID not found in URL. Please scan a valid QR code or use a direct link with ID.';
        messageDiv.classList.add('text-red-600');
    }
});
