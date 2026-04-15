const fetch = require('node-fetch'); // npm install node-fetch@2

exports.scanBarcode = async (req, res) => {
  const { barcode } = req.params;

  try {
    const response = await fetch(
      `https://world.openfoodfacts.org/api/v0/product/${barcode}.json`
    );
    const data = await response.json();

    if (data.status === 0) {
      return res.status(404).json({ message: 'Produit non trouvé' });
    }

    const p = data.product;
    const nutriments = p.nutriments || {};

    return res.json({
      name: p.product_name || 'Inconnu',
      brand: p.brands || '',
      image: p.image_url || '',
      quantity: p.quantity || '',
      nutriscore: p.nutriscore_grade || '',
      per100g: {
        calories:    nutriments['energy-kcal_100g']  || 0,
        proteins:    nutriments['proteins_100g']      || 0,
        carbs:       nutriments['carbohydrates_100g'] || 0,
        fat:         nutriments['fat_100g']           || 0,
        fiber:       nutriments['fiber_100g']         || 0,
        sugar:       nutriments['sugars_100g']        || 0,
        salt:        nutriments['salt_100g']          || 0,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Erreur serveur' });
  }
};