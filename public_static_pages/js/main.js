// public/js/main.js
import { fetchPublicVehicleDetails } from './api/firestore-api.js';
import { setContactInfo } from './services/contact-actions.js';
import {
    messageDiv,
    qrSection,
    qrCodeUuidSpan,
    qrCodeImage,
    vehicleInfoSection,
    vehicleDetailsList,
    ownerInfoSection,
    ownerDetailsList,
    emergencyContactsSection,
    emergencyContactsList,
    makeCallButton, // Imported for visibility control
    makeCallECButton, // Imported for visibility control
    sosButton, // Imported for visibility control
    getQrCodeUuidFromUrl,
    populateDetailsList,
    formatKey // Imported for use in createDetailRow
} from './utils/dom-utils.js';

/**
 * Helper function to create a standardized detail row.
 * @param {string} label The label for the detail (e.g., "Name").
 * @param {string} value The value of the detail.
 * @returns {string} HTML string for the detail row.
 */
function createDetailRow(label, value) {
    return `
        <div class="flex justify-between py-2 border-b border-dashed border-gray-200 last:border-b-0">
            <span class="font-semibold text-gray-600">${label}:</span>
            <span class="text-gray-700 text-right">${value}</span>
        </div>
    `;
}

/**
 * Displays the fetched vehicle details on the page.
 * @param {Object} data The public vehicle data.
 */
function displayVehicleDetails(data) {
    messageDiv.classList.add('hidden'); // Hide loading message

    // QR Code Section
    qrCodeUuidSpan.textContent = data.qrCodeUuid || 'N/A';
    if (data.qrCodeImageUrl) {
        qrCodeImage.src = data.qrCodeImageUrl;
    } else {
        qrCodeImage.src = "https://placehold.co/150x150/E0E0E0/FFFFFF?text=QR";
    }
    qrSection.classList.remove('hidden');

    // Owner Information - Custom display order and content
    if (data.ownerPublicInfo) {
        let ownerContent = '';

        // Add Name (from fullName field)
        const ownerName = data.ownerPublicInfo.fullName || 'N/A';
        ownerContent += createDetailRow('Name', ownerName);

        // Add Vehicle Number from vehiclePublicInfo
        const vehicleNumber = data.vehiclePublicInfo?.vehicleNumber || 'N/A';
        ownerContent += createDetailRow('Vehicle Number', vehicleNumber);

        // Add other specified owner fields in order
        ownerContent += createDetailRow('Medical Conditions', data.ownerPublicInfo.medicalConditions || 'N/A');
        ownerContent += createDetailRow('Medications', data.ownerPublicInfo.medications || 'N/A');
        ownerContent += createDetailRow('Blood Group', data.ownerPublicInfo.bloodGroup || 'N/A');
        ownerContent += createDetailRow('Preferred Hospital', data.ownerPublicInfo.preferredHospital || 'N/A');
        ownerContent += createDetailRow('Known Allergies', data.ownerPublicInfo.knownAllergies || 'N/A');

        ownerDetailsList.innerHTML = ownerContent;
        ownerInfoSection.classList.remove('hidden');
    } else {
        ownerDetailsList.innerHTML = '<p class="text-gray-500">No owner information available.</p>';
        ownerInfoSection.classList.remove('hidden');
    }

    // Emergency Contacts Section - Custom header and display (Relation text-right aligned)
    const emergencyContacts = data.ownerPublicInfo?.emergencyContacts || [];
    if (emergencyContacts.length > 0) {
        emergencyContactsList.innerHTML = `
            <div class="flex font-bold text-gray-800 border-b-2 border-gray-300 pb-2 mb-2">
                <span class="w-1/2 text-left">Name</span>
                <span class="w-1/2 text-right">Relation</span>
            </div>
        `; // Header row adjusted for right-alignment of Relation

        emergencyContacts.forEach((contact, index) => {
            const contactDiv = document.createElement('div');
            contactDiv.className = 'flex justify-between items-center py-2 border-b border-dashed border-gray-200 last:border-b-0';
            contactDiv.innerHTML = `
                <span class="w-1/2 text-left text-gray-700">${contact.name || 'N/A'}</span>
                <span class="w-1/2 text-right text-gray-500">${contact.relationship || 'N/A'}</span>
            `; // Contact item adjusted for right-alignment of Relation
            emergencyContactsList.appendChild(contactDiv);
        });
        emergencyContactsSection.classList.remove('hidden');
    } else {
        emergencyContactsList.innerHTML = '<p class="text-gray-500">No emergency contacts listed.</p>';
        emergencyContactsSection.classList.remove('hidden');
    }

    // Other Vehicle Information - Remaining details
    if (data.vehiclePublicInfo) {
        populateDetailsList(vehicleDetailsList, data.vehiclePublicInfo, ['qrCodeUuid', 'ownerUserId', 'vehicleNumber']);
        vehicleInfoSection.classList.remove('hidden');
    } else {
        vehicleDetailsList.innerHTML = '<p class="text-gray-500">No other vehicle information available.</p>';
        vehicleInfoSection.classList.remove('hidden');
    }

    // Update contact info for action buttons (this populates variables used by click handlers)
    setContactInfo(data.ownerPublicInfo?.primaryPhoneNumber, data.ownerPublicInfo?.emergencyContacts);

    // Make the buttons visible only AFTER Firebase call and all data rendering
    if (makeCallButton) makeCallButton.classList.remove('hidden');
    if (makeCallECButton) makeCallECButton.classList.remove('hidden');
    if (sosButton) sosButton.classList.remove('hidden');
}

// Initial fetch when the page loads
document.addEventListener('DOMContentLoaded', async () => {
    const qrCodeUuid = getQrCodeUuidFromUrl();
    if (qrCodeUuid) {
        // Show loading message initially
        messageDiv.textContent = 'Loading details...';
        messageDiv.classList.remove('hidden');

        // Explicitly hide buttons at start of JS execution
        if (makeCallButton) makeCallButton.classList.add('hidden');
        if (makeCallECButton) makeCallECButton.classList.add('hidden');
        if (sosButton) sosButton.classList.add('hidden');

        const data = await fetchPublicVehicleDetails(qrCodeUuid);
        if (data) {
            displayVehicleDetails(data);
        } else {
            messageDiv.textContent = 'Vehicle details not found for the provided QR Code ID.';
            messageDiv.classList.remove('hidden');
            messageDiv.classList.add('text-red-600');
        }
    } else {
        messageDiv.textContent = 'QR Code ID not found in URL. Please scan a valid QR code or use a direct link with ID.';
        messageDiv.classList.remove('hidden');
        messageDiv.classList.add('text-red-600');
    }
});