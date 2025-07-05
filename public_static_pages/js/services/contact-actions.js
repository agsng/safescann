// public/js/services/contact-actions.js
import { showModal, makeCallButton, sosButton } from '../utils/dom-utils.js';

let ownerPrimaryPhoneNumber = '';
let emergencyContacts = [];

/**
 * Sets the contact information for the action buttons.
 * This function should be called after fetching public vehicle details.
 * @param {string} primaryPhone The owner's primary phone number.
 * @param {Array<Object>} contacts An array of emergency contact objects.
 */
function setContactInfo(primaryPhone, contacts) {
    ownerPrimaryPhoneNumber = primaryPhone || '';
    emergencyContacts = contacts || [];

    // Show/hide buttons based on contact info availability
    if (ownerPrimaryPhoneNumber || emergencyContacts.length > 0) {
        makeCallButton.classList.remove('hidden');
        sosButton.classList.remove('hidden');
    } else {
        makeCallButton.classList.add('hidden');
        sosButton.classList.add('hidden');
    }
}

// Event Listeners for Buttons
makeCallButton.addEventListener('click', () => {
    if (ownerPrimaryPhoneNumber) {
        showModal(`Call ${ownerPrimaryPhoneNumber}?`, [
            { text: 'Call', type: 'primary', handler: () => window.location.href = `tel:${ownerPrimaryPhoneNumber}` },
            { text: 'Cancel', type: 'default', handler: () => {} }
        ]);
    } else if (emergencyContacts.length > 0 && emergencyContacts[0].phone) {
        showModal(`No primary number. Call emergency contact ${emergencyContacts[0].name || '1'} (${emergencyContacts[0].phone})?`, [
            { text: 'Call', type: 'primary', handler: () => window.location.href = `tel:${emergencyContacts[0].phone}` },
            { text: 'Cancel', type: 'default', handler: () => {} }
        ]);
    } else {
        showModal('No phone number available for primary or emergency contacts.');
    }
});

sosButton.addEventListener('click', () => {
    let sosMessage = 'Attempting to send SOS. This feature requires backend integration for full functionality (e.g., sending SMS, location).';
    let actions = [];

    if (emergencyContacts.length > 0) {
        const firstContactPhone = emergencyContacts[0].phone;
        if (firstContactPhone) {
            sosMessage += `\n\nInitiating call to first emergency contact: ${emergencyContacts[0].name || 'Contact 1'} (${firstContactPhone}).`;
            actions.push({ text: 'Call SOS Contact', type: 'danger', handler: () => window.location.href = `tel:${firstContactPhone}` });
        }
    } else {
        sosMessage += '\n\nNo emergency contacts configured.';
    }

    actions.push({ text: 'Close', type: 'default', handler: () => {} });

    showModal(sosMessage, actions);
});

export { setContactInfo };
