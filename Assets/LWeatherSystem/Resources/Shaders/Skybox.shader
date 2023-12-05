Shader "LWeatherSystem/Skybox"
{
    Properties
    {
        [NoScaleOffset] _SunZenithGrad ("Sun-Zenith gradient", 2D) = "white" {}
        [NoScaleOffset] _ViewZenithGrad ("View-Zenith gradient", 2D) = "white" {}
        [NoScaleOffset] _SunViewGrad ("Sun-View gradient", 2D) = "white" {}
        [NoScaleOffset] _MoonTexture ("Moon texture", 2D) = "white" {}
        _CloudColor("cloud color",Color)=(1,1,1,1)
		_CloudSpeed("cloud speed",float)=2
		//_CloudDensity("cloud density",range(0,1.1))=0.75
		_CloudNumber("cloud number",range(0,3))=1.0
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #define UNITY_PI  3.14159265359f
            #define UNITY_TWO_PI  6.28318530718f
            struct Attributes
            {
                float4 posOS    : POSITION;
                float3 uv       : TEXCOORD0;
            };

            struct v2f
            {
                float4 posCS        : SV_POSITION;
                float3 viewDirWS    : TEXCOORD0;
                float3 uv           : TEXCOORD1;
                float3 view : TEXCOORD3;
            };

            float4x4 _SunSpaceMatrix;

            v2f Vertex(Attributes IN)
            {
                v2f OUT = (v2f)0;
    
                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.posOS.xyz);
    
                OUT.posCS = vertexInput.positionCS;
                OUT.viewDirWS = vertexInput.positionWS;
                OUT.uv = mul(IN.uv,_SunSpaceMatrix);
                OUT.view = GetWorldSpaceViewDir(vertexInput.positionWS);
                return OUT;
            }

            TEXTURE2D(_SunZenithGrad);      SAMPLER(sampler_SunZenithGrad);
            TEXTURE2D(_ViewZenithGrad);     SAMPLER(sampler_ViewZenithGrad);
            TEXTURE2D(_SunViewGrad);        SAMPLER(sampler_SunViewGrad);
            TEXTURE2D(_MoonTexture);        SAMPLER(sampler_MoonTexture);

            float3 _SunDir, _MoonDir;
            float _SunRadius;
            float _SunBloom;
            float _HorizonHaze;
            float _MoonRadius;
            float _MoonIntensity;
            float4 _MoonColor;
            float4 _CloudColor;
			float _CloudSpeed;
			float _CloudDensity;
			float _CloudNumber;
            float Origin(float2 uv)
            {
                return 1 - smoothstep(0,1,length(uv * _SunRadius));
            }
            float Blur(float2 uv)
            {
                float offset = 0.0625f;
                
                // 左上
                float color =  Origin(float2(uv.x - offset,uv.y - offset)) * 0.0947416f;
                // 上
                color += Origin(float2(uv.x,uv.y - offset)) * 0.118318f;
                // 右上
                color += Origin(float2(uv.x + offset,uv.y + offset)) * 0.0947416f;
                // 左
                color += Origin(float2(uv.x - offset,uv.y)) * 0.118318f;
                // 中
                color += Origin(float2(uv.x,uv.y)) * 0.147761f;
                // 右
                color += Origin(float2(uv.x + offset,uv.y)) * 0.118318f;
                // 左下
                color += Origin(float2(uv.x - offset,uv.y + offset)) * 0.0947416f;
                // 下
                color += Origin(float2(uv.x,uv.y + offset)) * 0.118318f;
                // 右下
                color += Origin(float2(uv.x + offset,uv.y - offset)) * 0.0947416f;
                return color;
            }
            float noise(float2 uv)
			{
				return sin(1.5*uv.x)*sin(1.5*uv.y);
			}
			
			float fbm(float2 p,int n)
			{
				float2x2 m = float2x2(0.6,0.8,-0.8,0.6);
				float f = 0.0;
				float a = 0.5;
				for(int i=0;i<n;i++)
				{
					f += a * (_CloudDensity+0.5*noise(p));
					p = mul(p,m)*2.0;
					a *=0.5;
				}
				return f;
			}
			float cloud(float2 uv)
			{
				float _sin = sin(_CloudSpeed*0.05*_Time.x);
				float _cos = cos(_CloudSpeed*0.05*_Time.x);
				uv = float2((_cos*uv.x+_sin*uv.y),-_sin*uv.x+_cos*uv.y);
				float2 o = float2(fbm(uv,6),fbm(uv+1.2,6));				
				float ol = length(o);
				o += 0.05*float2((_CloudSpeed*1.35*_Time.x+ol),(_CloudSpeed*1.5*_Time.x+ol));
				o *= 2;
			    float2 n = float2(fbm(o+9,6),fbm(o+5,6));
				float f = fbm(2*(uv + n),4);
				f = f*0.5 + smoothstep(0,1,pow(f,3)*pow(n.x,2))*0.5 + smoothstep(0,1,pow(f,5)*pow(n.y,2))*0.5;
				return smoothstep(0,2,f);
			}
            float GetSunMask(float sunViewDot, float sunRadius)
            {
                float stepRadius = 1 - sunRadius * sunRadius;
                return step(stepRadius, sunViewDot);
            }
            float4 Fragment (v2f IN) : SV_TARGET
            {
                float3 viewDir = normalize(IN.viewDirWS);

                // Main angles
                float sunViewDot = dot(_SunDir, viewDir);
                float sunZenithDot = _SunDir.y;
                float viewZenithDot = viewDir.y;
                float sunMoonDot = dot(_SunDir, _MoonDir);

                float sunViewDot01 = (sunViewDot + 1.0) * 0.5;
                float sunZenithDot01 = (sunZenithDot + 1.0) * 0.5;

                // Sky colours
                float3 sunZenithColor = SAMPLE_TEXTURE2D(_SunZenithGrad, sampler_SunZenithGrad, float2(sunZenithDot01, 0.5)).rgb;

                // Horizon haze
                float3 viewZenithColor = SAMPLE_TEXTURE2D(_ViewZenithGrad, sampler_ViewZenithGrad, float2(sunZenithDot01, 0.5)).rgb;
                float vzMask = pow(saturate(1.0 - viewZenithDot), _HorizonHaze);

                // Sun bloom
                float3 sunViewColor = SAMPLE_TEXTURE2D(_SunViewGrad, sampler_SunViewGrad, float2(sunZenithDot01, 0.5)).rgb;
                float svMask = pow(saturate(sunViewDot), _SunBloom);

                float3 skyColor = sunZenithColor + vzMask * viewZenithColor + svMask * sunViewColor;

                // The sun
                float sunMask = Blur(IN.uv.xy) * step(IN.uv.z, 0);
                float3 sunColor = _MainLightColor.rgb * sunMask;

                float3 moonColor = SAMPLE_TEXTURE2D(_MoonTexture, sampler_MoonTexture, IN.uv.xy * _MoonRadius + float2(0.5,0.5)) * step(0, IN.uv.z);
                //moonColor = _MoonColor.rgb * moonColor;
                float3 scattering = Blur(IN.uv.xy) * step(0, IN.uv.z) * _MoonColor.rgb;
                moonColor = moonColor * (1 - _MoonIntensity) + scattering * _MoonIntensity;
                
                viewDir = normalize(IN.view);
                float2 uv = float2((atan2(viewDir.x, viewDir.z) + UNITY_PI) / UNITY_TWO_PI,acos(viewDir.y) / UNITY_PI);
                float y = min(viewDir.y+1.0,1.0);
				float s = 0.5*(1.0+0.4*tan(1.9+2.5*y));
				float th = uv.x * UNITY_PI * 2.0;
				float2 _uv = float2(sin(th)*0.5, cos(th)*0.5)*s*5*_CloudNumber + 0.5;
				float c = cloud(_uv*(s+1.0));
				c *= smoothstep(0.0,0.4,y)*smoothstep(0.0,0.15,1.0-y);
                float3 col = skyColor + sunColor + moonColor;
                //float4(col, 1)
                //_CloudColor = float4(exp(-c), exp(-c),exp(-c),1);
                //_CloudColor = smoothstep(_CloudColor, float4(0.582,0.5445672,0.4580339,1), c);
                return lerp(float4(col, 1), _CloudColor,c*_CloudColor.a);
            }
            ENDHLSL
        }
    }
}