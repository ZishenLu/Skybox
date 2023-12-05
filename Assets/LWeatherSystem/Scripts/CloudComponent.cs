using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class CloudComponent : IComponent
{
    [Range(0f, 1f)]
    public float Density = 0.75f;

    [ColorUsage(false)]
    public Color Color = Color.white;

    private void LateUpdate()
    {
        m_skyboxController.SkyboxMat.SetFloat("_CloudDensity", Density);
        //m_skyboxController.SkyboxMat.SetColor("_CloudColor", Color);
    }
}