// public/js/services/contact-actions.js
// Make sure all necessary DOM elements are imported
import { showModal, makeCallButton, sosButton, makeCallECButton, modal, closeButton, modalMessage, modalActions } from '../utils/dom-utils.js';

let ownerPrimaryPhoneNumber = '';
let emergencyContacts = [];

/**
 * Sets the contact information for the action buttons.
 * This function should be called after fetching public vehicle details.
 * It no longer controls button visibility based on initial data.
 * @param {string} primaryPhone The owner's primary phone number.
 * @param {Array<Object>} contacts An array of emergency contact objects.
 */
export function setContactInfo(primaryPhone, contacts) {
    ownerPrimaryPhoneNumber = primaryPhone || '';
    emergencyContacts = contacts || [];

    // Removed the logic to add/remove 'hidden' class here.
    // Buttons are now assumed to be always visible from HTML.

    // SOS button might always be visible, or based on another condition
    // sosButton.classList.remove('hidden'); // Assuming SOS is always available - this line can stay or be removed if 'hidden' is gone from HTML
}

// Event Listeners for Buttons
document.addEventListener('DOMContentLoaded', () => { // Ensure DOM is loaded before adding listeners
    if (makeCallButton) {
        makeCallButton.addEventListener('click', () => {
            if (ownerPrimaryPhoneNumber) {
                showModal(`Call ${ownerPrimaryPhoneNumber}?`, [
                    { text: 'Call', type: 'primary', handler: () => window.location.href = `tel:${ownerPrimaryPhoneNumber}` },
                    { text: 'Cancel', type: 'default', handler: () => {} }
                ]);
            } else if (emergencyContacts.length > 0 && emergencyContacts[0].phone) {
                // Fallback to first emergency contact if primary is not available
                showModal(`No primary number. Call emergency contact ${emergencyContacts[0].name || '1'} (${emergencyContacts[0].phone})?`, [
                    { text: 'Call', type: 'primary', handler: () => window.location.href = `tel:${emergencyContacts[0].phone}` },
                    { text: 'Cancel', type: 'default', handler: () => {} }
                ]);
            } else {
                showModal('No primary or emergency phone number available.'); // Updated message
            }
        });
    }

    if (makeCallECButton) { // Event listener for the Emergency Contact Button
        makeCallECButton.addEventListener('click', () => {
            if (emergencyContacts.length > 0) {
                modalMessage.textContent = "Select an emergency contact to call:";
                modalActions.innerHTML = ''; // Clear previous buttons

                emergencyContacts.forEach(contact => {
                    const callBtn = document.createElement('button');
                    callBtn.textContent = `Call ${contact.name}`;
                    // Add Tailwind classes for modal buttons
                    callBtn.className = 'bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded transition-all duration-200 ease-in-out';
                    callBtn.onclick = () => {
                        window.location.href = `tel:${contact.phone}`;
                        modal.classList.add('hidden'); // Close modal after click
                    };
                    modalActions.appendChild(callBtn);
                });
                modal.classList.remove('hidden'); // Show the modal
            } else {
                modalMessage.textContent = "No emergency contacts available.";
                modalActions.innerHTML = ''; // Ensure no buttons if no contacts
                modal.classList.remove('hidden'); // Show modal with message
            }
        });
    }

    if (sosButton) {
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
                sosMessage += '\n\nNo emergency contacts configured for immediate call.'; // Updated message
            }

            actions.push({ text: 'Close', type: 'default', handler: () => {} });

            showModal(sosMessage, actions);
        });
    }

    // Modal close handlers (using classList for consistency)
   if (closeButton) {
       closeButton.onclick = function() {
           modal.classList.add('hidden');
       };
   }

    if (modal) {
        window.onclick = function(event) {
            if (event.target === modal) {
                modal.classList.add('hidden');
            }
        };
    }
});