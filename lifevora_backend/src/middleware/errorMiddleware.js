const errorMiddleware = (err, req, res, next) => {
    console.error('❌ Erreur:', err.message);

    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({
            success: false,
            message: 'Cet email est déjà utilisé'
        });
    }

    res.status(err.status || 500).json({
        success: false,
        message: err.message || 'Erreur interne du serveur'
    });
};

const notFoundMiddleware = (req, res) => {
    res.status(404).json({
        success: false,
        message: `Route ${req.method} ${req.url} non trouvée`
    });
};

module.exports = { errorMiddleware, notFoundMiddleware };