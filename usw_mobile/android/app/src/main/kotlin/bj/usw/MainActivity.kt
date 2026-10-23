package bj.usw

import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        frequenceMaximale()
    }

    // Beaucoup de telephones laissent les applications a 60 Hz. On demande le
    // mode d affichage le plus rapide (90, 120 Hz) a la meme definition :
    // le defilement et les animations en deviennent plus fluides. Un ecran
    // a 60 Hz seulement (les anciens Android) reste tel quel.
    private fun frequenceMaximale() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val ecran = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else @Suppress("DEPRECATION") windowManager.defaultDisplay
        ecran ?: return
        val actuel = ecran.mode
        val meilleur = ecran.supportedModes
            .filter { it.physicalWidth == actuel.physicalWidth && it.physicalHeight == actuel.physicalHeight }
            .maxByOrNull { it.refreshRate } ?: return
        if (meilleur.refreshRate <= actuel.refreshRate + 0.5f) return
        val attributs = window.attributes
        attributs.preferredDisplayModeId = meilleur.modeId
        window.attributes = attributs
    }
}
