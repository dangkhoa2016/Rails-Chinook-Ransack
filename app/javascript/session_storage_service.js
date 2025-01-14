const prefix = 'rails-chinook-ransack-';

const getKey = (key) => {
  return `${prefix}${key}`;
}

class SessionStorageService {
  // Store data in sessionStorage
  static setItem(key, value) {
    try {
      sessionStorage.setItem(getKey(key), JSON.stringify(value)); // Convert object to JSON string before saving
    } catch (e) {
      console.error('Error saving to sessionStorage', e);
    }
  }

  // Retrieve data from sessionStorage
  static getItem(key) {
    try {
      const value = sessionStorage.getItem(getKey(key));
      return value ? JSON.parse(value) : null; // Parse JSON string back to object
    } catch (e) {
      console.error('Error reading from sessionStorage', e);
      return null;
    }
  }

  // Remove a specific item from sessionStorage
  static removeItem(key) {
    try {
      sessionStorage.removeItem(getKey(key));
    } catch (e) {
      console.error('Error removing item from sessionStorage', e);
    }
  }

  // Clear all data from sessionStorage
  static clear() {
    try {
      sessionStorage.clear();
    } catch (e) {
      console.error('Error clearing sessionStorage', e);
    }
  }

  // Check if a specific item exists in sessionStorage
  static hasItem(key) {
    return sessionStorage.getItem(getKey(key)) !== null;
  }

}

export default SessionStorageService;
