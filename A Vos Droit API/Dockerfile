FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 7076
EXPOSE 5005

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["A Vos Droits API/A Vos Droits API.csproj", "A Vos Droits API/"]
RUN dotnet restore "A Vos Droits API/A Vos Droits API.csproj"
COPY . .
WORKDIR "/src/A Vos Droits API"
RUN dotnet build "A Vos Droits API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "A Vos Droits API.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create directory for uploads
RUN mkdir -p /app/Uploads/Documents

# Set ASP.NET Core environment variables
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_URLS=https://+:7076;http://+:5005
ENV ASPNETCORE_Kestrel__Certificates__Default__Path=/app/cert/dev-cert.pfx
ENV ASPNETCORE_Kestrel__Certificates__Default__Password=dev-cert-password

# Create directory for certificate
RUN mkdir -p /app/cert

ENTRYPOINT ["dotnet", "A Vos Droits API.dll"] 