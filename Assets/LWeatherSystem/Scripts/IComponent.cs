using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IComponent : MonoBehaviour
{
    protected SkyboxController m_skyboxController;

    void Awake()
    {
        m_skyboxController = GetComponentInParent<SkyboxController>();
    }
}
