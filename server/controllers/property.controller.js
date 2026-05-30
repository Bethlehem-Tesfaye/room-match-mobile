const { readCollection, writeCollection } = require('../utils/jsonDb');
const { generateId } = require('../utils/ids');
const { sanitizeUser } = require('../utils/userResponse');

function matchesSearch(property, query) {
  if (!query) return true;
  const q = query.toLowerCase();
  return (
    property.title?.toLowerCase().includes(q) ||
    property.location?.toLowerCase().includes(q) ||
    property.address?.toLowerCase().includes(q)
  );
}

function listProperties(req, res) {
  try {
    const {
      search,
      maxBudget,
      propertyType,
      bedrooms,
      ownerId,
      verified,
    } = req.query;

    let properties = readCollection('properties');

    if (ownerId) {
      properties = properties.filter((p) => p.ownerId === ownerId);
    }

    if (verified === 'true') {
      properties = properties.filter((p) => p.verified);
    }

    properties = properties.filter((p) => matchesSearch(p, search));

    if (maxBudget) {
      const budget = Number(maxBudget);
      if (!Number.isNaN(budget)) {
        properties = properties.filter((p) => p.rentAmount <= budget);
      }
    }

    if (propertyType) {
      properties = properties.filter(
        (p) => p.propertyType?.toLowerCase() === propertyType.toLowerCase(),
      );
    }

    if (bedrooms) {
      const beds = Number(bedrooms);
      if (!Number.isNaN(beds)) {
        properties = properties.filter((p) => p.bedrooms === beds);
      }
    }

    properties.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    return res.json(properties);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch properties' });
  }
}

function getProperty(req, res) {
  try {
    const properties = readCollection('properties');
    const property = properties.find((p) => p.id === req.params.id);

    if (!property) {
      return res.status(404).json({ message: 'Property not found' });
    }

    const users = readCollection('users');
    const owner = users.find((u) => u.id === property.ownerId);

    return res.json({
      ...property,
      owner: owner ? sanitizeUser(owner) : null,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to fetch property' });
  }
}

function createProperty(req, res) {
  try {
    const {
      title,
      rentAmount,
      propertyType,
      bedrooms,
      location,
      address,
      phone,
      email,
      amenities,
      availabilityDate,
      leaseLength,
    } = req.body;

    if (!title?.trim() || !rentAmount || !address?.trim()) {
      return res.status(400).json({
        message: 'Title, rent amount, and address are required',
      });
    }

    const images = (req.files || []).map((f) => `/uploads/${f.filename}`);

    const property = {
      id: generateId('prop'),
      ownerId: req.user.id,
      title: title.trim(),
      rentAmount: Number(rentAmount),
      propertyType: propertyType || 'Apartment',
      bedrooms: Number(bedrooms) || 1,
      location: location?.trim() || address.trim().split(',')[0].trim(),
      address: address.trim(),
      phone: phone?.trim() || '',
      email: email?.trim() || req.user.email,
      amenities: parseAmenities(amenities),
      availabilityDate: availabilityDate || new Date().toISOString().slice(0, 10),
      leaseLength: leaseLength || '12 Months',
      images,
      verified: false,
      createdAt: new Date().toISOString(),
    };

    const properties = readCollection('properties');
    properties.push(property);
    writeCollection('properties', properties);

    return res.status(201).json(property);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to create property' });
  }
}

function updateProperty(req, res) {
  try {
    const properties = readCollection('properties');
    const index = properties.findIndex((p) => p.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ message: 'Property not found' });
    }

    const property = properties[index];
    if (property.ownerId !== req.user.id) {
      return res.status(403).json({ message: 'You can only edit your own listings' });
    }

    const fields = [
      'title',
      'rentAmount',
      'propertyType',
      'bedrooms',
      'location',
      'address',
      'phone',
      'email',
      'availabilityDate',
      'leaseLength',
    ];

    for (const field of fields) {
      if (req.body[field] !== undefined) {
        property[field] =
          field === 'rentAmount' || field === 'bedrooms'
            ? Number(req.body[field])
            : String(req.body[field]).trim();
      }
    }

    if (req.body.amenities !== undefined) {
      property.amenities = parseAmenities(req.body.amenities);
    }

    if (req.files?.length) {
      const newImages = req.files.map((f) => `/uploads/${f.filename}`);
      property.images = [...(property.images || []), ...newImages];
    }

    properties[index] = property;
    writeCollection('properties', properties);

    return res.json(property);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to update property' });
  }
}

function deleteProperty(req, res) {
  try {
    const properties = readCollection('properties');
    const index = properties.findIndex((p) => p.id === req.params.id);

    if (index === -1) {
      return res.status(404).json({ message: 'Property not found' });
    }

    if (properties[index].ownerId !== req.user.id) {
      return res.status(403).json({ message: 'You can only delete your own listings' });
    }

    properties.splice(index, 1);
    writeCollection('properties', properties);

    return res.json({ message: 'Property deleted' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Failed to delete property' });
  }
}

function parseAmenities(value) {
  if (Array.isArray(value)) return value;
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      if (Array.isArray(parsed)) return parsed;
    } catch {
      return value.split(',').map((s) => s.trim()).filter(Boolean);
    }
  }
  return [];
}

module.exports = {
  listProperties,
  getProperty,
  createProperty,
  updateProperty,
  deleteProperty,
};
