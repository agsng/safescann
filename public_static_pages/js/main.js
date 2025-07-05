// public/js/main.js
import { fetchPublicVehicleDetails } from './api/firestore-api.js';
import { setContactInfo } from './services/contact-actions.js';
import {
    messageDiv,
    qrSection,
    qrCodeUuidSpan,
    qrCodeImage, // *** IMPORTED QR CODE IMAGE ***
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
    if (data.qrCodeImageUrl) { // Assuming qrCodeImageUrl comes with data
        qrCodeImage.src = data.qrCodeImageUrl;
    } else {
        // Fallback or ensure default placeholder is shown if no image URL
        qrCodeImage.src = "https://placehold.co/150x150/E0E0E0/FFFFFF?text=QR";
    }
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

        // Set contact info for action buttons (this function handles button visibility)
        setContactInfo(data.ownerPublicInfo.primaryPhoneNumber, data.ownerPublicInfo.emergencyContacts);
    }

    // Emergency Contacts
    const emergencyContacts = data.ownerPublicInfo?.emergencyContacts || [];
    if (emergencyContacts.length > 0) {
        emergencyContactsList.innerHTML = ''; // Clear previous content
        emergencyContacts.forEach((contact, index) => {
            const contactDiv = document.createElement('div');
            // Use Tailwind classes directly for emergency contact list items
            contactDiv.className = 'flex justify-between items-center py-2 border-b border-dashed border-gray-200 last:border-b-0';
            contactDiv.innerHTML = `
                <div class="flex-grow text-left">
                    <span class="font-semibold text-gray-700">${contact.name || 'N/A'}</span>
                    <p class="text-sm text-gray-500">${contact.relationship || 'N/A'}</p>
                </div>
                ${contact.phone ? `
                    <a href="tel:${contact.phone}" class="flex-shrink-0 inline-flex items-center px-3 py-1.5 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-500 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                        <svg class="-ml-0.5 mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                            <path fill-rule="evenodd" d="M1.5 4.5a3 3 0 0 1 3-3h1.372c.86 0 1.61.586 1.854 1.442L8.75 7.5c.243.856-.113 1.77-.93 2.324l-.005.003-.004.002a6.734 6.734 0 0 0 4.908 4.908l.003-.004.002-.005c.554-.817 1.468-1.173 2.324-.93l3.056 1.186c.856.243 1.442 1.003 1.442 1.854V19.5a3 3 0 0 1-3 3H15c-1.173 0-2.23-.553-2.916-1.413A11.908 11.908 0 0 1 8.012 10.5c-.86-.686-1.413-1.743-1.413-2.916V4.5a3 3 0 0 1 3-3H4.5a3 3 0 0 1-3 3Z" clip-rule="evenodd" />
                        </svg>
                        Call
                    </a>` : ''}
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
        // This relies on your fetchPublicVehicleDetails from firestore-api.js to work correctly.
        // Ensure it returns an object with qrCodeUuid, vehiclePublicInfo, ownerPublicInfo (including emergencyContacts)
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
        messageDiv.classList.add('text-red-600');
    }
});