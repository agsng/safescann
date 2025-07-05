// public/js/utils/dom-utils.js

// DOM Elements
const messageDiv = document.getElementById('message');
const qrSection = document.getElementById('qr-section');
const qrCodeUuidSpan = document.getElementById('qr-code-uuid');
const qrCodeImage = document.getElementById('qr-code-image'); // Get the QR code image element
const vehicleInfoSection = document.getElementById('vehicle-info-section');
const vehicleDetailsList = document.getElementById('vehicle-details-list');
const ownerInfoSection = document.getElementById('owner-info-section');
const ownerDetailsList = document.getElementById('owner-details-list');
const emergencyContactsSection = document.getElementById('emergency-contacts-section');
const emergencyContactsList = document.getElementById('emergency-contacts-list');
const makeCallButton = document.getElementById('make-call-button');
const makeCallECButton = document.getElementById('make-call-ec-button');
const sosButton = document.getElementById('sos-button');

// Modal Elements
const modal = document.getElementById('myModal');
const closeButton = document.getElementsByClassName('close-button')[0]; // The 'x' close button inside modal
const modalMessage = document.getElementById('modal-message');
const modalActions = document.getElementById('modal-actions');

/**
 * Function to show custom modal using Tailwind's 'hidden' class.
 * @param {string} message The message to display in the modal.
 * @param {Array<Object>} [actions=[]] Optional array of action buttons for the modal.
 */
function showModal(message, actions = []) {
    modalMessage.textContent = message;
    modalActions.innerHTML = ''; // Clear previous actions

    actions.forEach(action => {
        const button = document.createElement('button');
        button.textContent = action.text;
        // Apply Tailwind classes directly for modal action buttons
        button.className = 'px-4 py-2 rounded-lg font-semibold transition-colors duration-200';
        if (action.type === 'primary') {
            button.classList.add('bg-blue-500', 'text-white', 'hover:bg-blue-600');
        } else if (action.type === 'danger') {
            button.classList.add('bg-red-500', 'text-white', 'hover:bg-red-600');
        } else {
            button.classList.add('bg-gray-200', 'text-gray-800', 'hover:bg-gray-300');
        }
        button.onclick = () => {
            action.handler();
            modal.classList.add('hidden'); // Close modal after action, use hidden class
        };
        modalActions.appendChild(button);
    });

    modal.classList.remove('hidden'); // Show modal by removing 'hidden' class
}

// Event listeners for closing modal are best handled in contact-actions.js for modularity,
// but included simple checks here for robustness in case.
if (closeButton) {
    closeButton.onclick = function() {
        if (modal) modal.classList.add('hidden');
    };
}
if (modal) {
    window.onclick = function(event) {
        if (event.target === modal) {
            modal.classList.add('hidden');
        }
    };
}


/**
 * Extracts the QR Code UUID from the URL, supporting both query parameters (?id=...)
 * and path parameters (/details/...).
 * @returns {string|null} The QR Code UUID or null if not found.
 */
function getQrCodeUuidFromUrl() {
    const urlParams = new URLSearchParams(window.location.search);
    const queryId = urlParams.get('id'); // Try to get from query parameter

    if (queryId) {
        return queryId;
    }

    // If not found in query, try to get from path parameter
    // Assumes URL structure like /details/YOUR_QR_CODE_UUID or /sos/YOUR_QR_CODE_UUID
    const pathSegments = window.location.pathname.split('/');
    // Filter out empty strings and 'details' or 'sos'
    const relevantSegments = pathSegments.filter(segment => segment && segment !== 'details' && segment !== 'sos');

    // The QR code UUID should be the last relevant segment
    if (relevantSegments.length > 0) {
        return relevantSegments[relevantSegments.length - 1];
    }

    return null; // No ID found in either query or path
}

/**
 * Populates a details list with key-value pairs using Tailwind classes.
 * @param {HTMLElement} listElement The HTML element (e.g., div) to populate.
 * @param {Object} data The object containing the details.
 * @param {string[]} [excludeKeys=[]] Optional array of keys to exclude from display.
 */
function populateDetailsList(listElement, data, excludeKeys = []) {
    listElement.innerHTML = ''; // Clear previous content
    if (!data || Object.keys(data).length === 0) {
        listElement.innerHTML = '<p class="text-gray-500">No details available.</p>';
        return;
    }
    for (const key in data) {
        if (data.hasOwnProperty(key) && !excludeKeys.includes(key)) {
            const value = data[key];
            if (value !== null && value !== undefined && value !== '') {
                const divItem = document.createElement('div');
                // *** IMPORTANT: Changed custom classes to direct Tailwind for styling ***
                divItem.className = 'flex justify-between py-2 border-b border-dashed border-gray-200 last:border-b-0';
                divItem.innerHTML = `
                    <span class="font-semibold text-gray-600">${formatKey(key)}:</span>
                    <span class="text-gray-700 text-right">${value}</span>
                `;
                listElement.appendChild(divItem);
            }
        }
    }
}

/**
 * Formats a camelCase key into a human-readable string.
 * @param {string} key The camelCase key.
 * @returns {string} The formatted string.
 */
function formatKey(key) {
    return key
        .replace(/([A-Z])/g, ' $1') // Add space before capital letters
        .replace(/^./, str => str.toUpperCase()) // Capitalize the first letter
        .trim();
}

// Export all relevant DOM elements and utility functions
export {
    messageDiv,
    qrSection,
    qrCodeUuidSpan,
    qrCodeImage, // *** EXPORTED QR CODE IMAGE ***
    vehicleInfoSection,
    vehicleDetailsList,
    ownerInfoSection,
    ownerDetailsList,
    emergencyContactsSection,
    emergencyContactsList,
    makeCallButton,
    makeCallECButton,
    sosButton,
    modal, // *** EXPORTED MODAL ***
    closeButton, // *** EXPORTED CLOSE BUTTON ***
    modalMessage, // *** EXPORTED MODAL MESSAGE ***
    modalActions, // *** EXPORTED MODAL ACTIONS ***
    showModal,
    getQrCodeUuidFromUrl,
    populateDetailsList,
    formatKey
};