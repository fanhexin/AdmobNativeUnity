using AdmobNative.Common;
using UnityEngine;

namespace AdmobNative
{
    public static class AdmobNativeExtension
    {
        private static Vector3[] _corners;
        
        public static void Show(this IAdmobNativeWrapper wrapper, RectTransform canvas, RectTransform adPlaceholder)
        {
            if (_corners == null)
            {
                _corners = new Vector3[4];
            }
            
            adPlaceholder.GetWorldCorners(_corners);
            Vector2 bottomLeft = canvas.InverseTransformPoint(_corners[0]);
            
            float canvasWidth = canvas.rect.width;
            float canvasHeight = canvas.rect.height;
            
            int x = (int) ((canvasWidth / 2 - Mathf.Abs(bottomLeft.x)) / canvasWidth * Screen.width);
            int y = (int) ((canvasHeight / 2 - Mathf.Abs(bottomLeft.y)) / canvasHeight * Screen.height);
            int width = (int) (adPlaceholder.rect.width / canvasWidth * Screen.width);
            int height = (int) (adPlaceholder.rect.height / canvasHeight * Screen.height);
            
            wrapper.Show(x, y, width, height);
        }
    }
}